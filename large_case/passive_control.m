%% 天然气系统及预警信号
gas_branch = xlsread('gas_branch1.xlsx');
gas_node = xlsread('gas_node1.xlsx');
gas_source = xlsread('gas_source1.xlsx');
gas_turbine = xlsread('gas_turbine1.xlsx');
c = 310;
[dead_node, dead_branch, dead_turbine] = topologize...
    (gas_node, gas_branch, gas_source, gas_turbine, [3,5,6,7], [18,19,21,22,24,25,33,34,35,45,46,49,50,54,55,60]);
gas_node([23,24,27,32,33,45],2) = 0;
ff = [];
for i=1:length(dead_turbine)
    if ~isempty(dead_turbine{i})
        ff = [ff, i];
    end
end
dead_node = dead_node(ff);
dead_branch = dead_branch(ff);
dead_turbine = dead_turbine(ff);
initial_LP = initial_LP_cal(gas_node, gas_branch, dead_branch, c);
final_LP = final_LP_cal(gas_branch, dead_branch, gas_turbine, dead_turbine, c);
ALP_0 = ALP_0_cal(initial_LP, final_LP);
SAET = SAET_cal(gas_node, dead_node, gas_turbine, dead_turbine, ALP_0);
[~, ~, ~, RATIO, ~, ~, ~, E_SERIAL] = idx_gas_turbine;
%% 电力系统紧急控制
mpc = zj;
gen = xlsread('generator.xlsx');
T = 4800;
n_generator = size(mpc.gen,1);% 机组个数
f_gen = cell(1,length(ff));
n_f_generator = cell(1,length(ff));
f_gen_ratio = cell(1,length(ff));
union_fgen = [];
for k=1:length(ff)
    f_gen{k} = gas_turbine(dead_turbine{k},E_SERIAL);% 故障机组序号
    union_fgen = union(union_fgen,f_gen{k});
    n_f_generator{k} = length(f_gen{k});% 故障机组个数
    f_gen_ratio{k} = gas_turbine(dead_turbine{k},RATIO);% 故障机组转换率
end
nf_gen = setdiff(1:n_generator,union_fgen);% 非故障机组序号
nf_gen = setdiff(nf_gen,[12,14,18,19]);
P_gen_0 = mpc.gen(:,2);% 所有机组初始出力
P_gen_0(P_gen_0>0.001) = P_gen_0(P_gen_0>0.001) - 0.001;% 修正
% 变量和参数
P_gen = sdpvar(n_generator,T,'full');% 所有机组出力
P_gen_max = gen(:,9);
ramp_d = 60/60.*P_gen_max;% 下爬坡速率/(MW/s)
ramp_u = gen(:,11)/60.*P_gen_max;% 上爬坡速率/(MW/s)
P_load = sdpvar(1,T,'full');
con = [];
for i=1:T
    con = [con,0<=P_gen(:,i)<=P_gen_max];% 上下限约束
    con = [con,P_load(i)==sum(P_gen(:,i))];% 潮流约束
end
con = [con,P_gen(:,1)==P_gen_0];% 发电初值约束
for i=2:T
    con = [con,-ramp_d(union_fgen)<=P_gen(union_fgen,i)-P_gen(union_fgen,i-1)<=0];% 故障机组爬坡约束
    con = [con,0<=P_gen(nf_gen,i)-P_gen(nf_gen,i-1)<=ramp_u(nf_gen)];% 非故障机组爬坡约束
    con = [con,0<=P_load(i)<=P_load(1)];% 最大负荷约束
end
for k=1:length(ff)
    for i=1:n_f_generator{k}
        con = [con,P_gen(f_gen{k}(i),2:min(T,ceil(SAET{k}(i)))-1)==P_gen_0(f_gen{k}(i))];
        con = [con,P_gen(f_gen{k}(i),min(T,ceil(SAET{k}(i))))==0];% 停机约束
    end
end
con = [con,P_gen([12,14,18,19],2:T)==0]; % 风电停机
y = T * P_load(1) - sum(P_load);
optimize(con,y)
z_gen = value(P_gen);
z_load = value(P_load);
z_loss = z_load(1) - z_load;
z_total_loss = sum(z_load(1) - z_load)/3600; % MWh