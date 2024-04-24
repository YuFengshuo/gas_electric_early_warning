% gas_node = xlsread('gas_node.xlsx');
% gas_branch = xlsread('gas_branch.xlsx');
% dead_branch = [1,2,3,4,5,6,7,8];
% c = 360;
function LP = initial_LP_cal(gas_node, gas_branch, dead_branch, c)
% % 计算初始LP，需要用到故障管道编号，节点气压，管长、管径，声速
[~, ~, PRESSURE, ~] = idx_gas_node;
[~, FROM, TO, ~, PIPE_L, PIPE_D, ~, ~, ~, ~] = idx_gas_branch;
for k=1:length(dead_branch)
    rho = 0*dead_branch{k};
    for i=1:length(dead_branch{k})
        f = gas_branch(dead_branch{k}(i),FROM);
        t = gas_branch(dead_branch{k}(i),TO);
        rho(i) = (gas_node(f,PRESSURE)+gas_node(t,PRESSURE))/2*10^5/c^2;% kg/m^3
    end
    pipe_length = gas_branch(dead_branch{k}, PIPE_L)';
    pipe_diameter = gas_branch(dead_branch{k}, PIPE_D)';
    LP_pipe = pi.*pipe_diameter.^2./4.*pipe_length.*1000.*rho;
    LP{k} = sum(LP_pipe);
end