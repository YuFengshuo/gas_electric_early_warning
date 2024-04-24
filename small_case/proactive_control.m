%% 天然气系统及预警信号
gas_branch = xlsread('gas_branch.xlsx');
gas_node = xlsread('gas_node.xlsx');
gas_source = xlsread('gas_source.xlsx');
gas_turbine = xlsread('gas_turbine.xlsx');
c = 390;
[dead_node, dead_branch, dead_turbine] = topologize...
    (gas_node, gas_branch, gas_source, gas_turbine, [], 1);
initial_LP = initial_LP_cal(gas_node, gas_branch, dead_branch, c);
final_LP = final_LP_cal(gas_branch, dead_branch, gas_turbine, dead_turbine, c);
ALP_0 = ALP_0_cal(initial_LP, final_LP);
SAET = SAET_cal(gas_node, dead_node, gas_turbine, dead_turbine, ALP_0);
%
SAET = SAET{1};
ALP_0 = ALP_0{1};
dead_turbine = dead_turbine{1};
[~, ~, ~, RATIO, ~, ~, ~, E_SERIAL] = idx_gas_turbine;
%% 电力系统紧急控制
load('zj_small.mat')
% SAET = ceil(SAET);
SAET = 473*ones(1,3);
T = 1200;
n_generator = size(zj_small.gen,1);% 机组个数
f_gen = gas_turbine(dead_turbine,E_SERIAL);% 故障机组序号
f_gen_ratio = gas_turbine(dead_turbine,RATIO);% 故障机组转换率
nf_gen = setdiff(1:n_generator,f_gen);% 非故障机组序号
n_f_generator = length(f_gen);% 故障机组个数
P_gen_0 = zj_small.gen(:,2);% 所有机组初始出力
P_gen_0(P_gen_0>0.001) = P_gen_0(P_gen_0>0.001) - 0.001;% 修正
% 变量和参数
P_gen = sdpvar(n_generator,T,'full');% 所有机组出力
P_gen_max = zj_small.gen(:,9);
ramp_d = 60/60.*P_gen_max;% 下爬坡速率/(MW/s)
ramp_u = 0.007/60.*P_gen_max;% 上爬坡速率/(MW/s)
P_load = sdpvar(1,T,'full');
con = [];
for i=1:T
    con = [con,0<=P_gen(:,i)<=P_gen_max];% 上下限约束
    con = [con,P_load(i)==sum(P_gen(:,i))];% 潮流约束
end
con = [con,P_gen(:,1)==P_gen_0];% 发电初值约束
for i=2:T
    con = [con,-ramp_d(f_gen)<=P_gen(f_gen,i)-P_gen(f_gen,i-1)<=0];% 故障机组爬坡约束
    con = [con,0<=P_gen(nf_gen,i)-P_gen(nf_gen,i-1)<=ramp_u(nf_gen)];% 非故障机组爬坡约束
    con = [con,0<=P_load(i)<=P_load(1)];% 最大负荷约束
end
for i=1:n_f_generator
    con = [con,P_gen(f_gen(i),SAET(i))==0];% 停机约束
    con = [con,sum(sum(P_gen(f_gen,:), 2)./f_gen_ratio)<=ALP_0(i)];% ALP约束
end
y = T * P_load(1) - sum(P_load);
optimize(con,y)
z_gen = value(P_gen);
z_load = value(P_load);
z_total_loss = sum(z_load(1) - z_load)/3600; % MWh
max_load_cut = max(value(P_load(1)-P_load)); % MW
ALP_r = ALP_0' - sum(sum(z_gen(f_gen,:), 2)./f_gen_ratio); % kg
