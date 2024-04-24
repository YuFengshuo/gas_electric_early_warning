% gas_branch = xlsread('gas_branch.xlsx');
% dead_branch = [1,2,3,4,5,6,7,8];
% gas_turbine = xlsread('gas_turbine.xlsx');
% dead_turbine = [1,2];
% c = 360;
function LP = final_LP_cal(gas_branch, dead_branch, gas_turbine, dead_turbine, c)
[~, ~, ~, ~, PIPE_L, PIPE_D, ~, ~, ~, ~] = idx_gas_branch;
[~, ~, ~, ~, MINPRESSURE, ~, ~] = idx_gas_turbine;
for k=1:length(dead_branch)
    n_failure = length(dead_turbine{k});
    LP{k} = zeros(1,n_failure);
    L = gas_branch(dead_branch{k},PIPE_L)';
    D = gas_branch(dead_branch{k},PIPE_D)';
    V_sum = sum(pi.*D.^2./4.*L*1000);
    for i=1:n_failure
        LP{k}(i) = gas_turbine(dead_turbine{k}(i),MINPRESSURE)*10^5/c^2*V_sum;
    end
end