% gas_node = xlsread('gas_node.xlsx');
% dead_node = [2,3,4,5,6,7,8];
% gas_turbine = xlsread('gas_turbine.xlsx');
% dead_turbine = [1,2];
% ALP = 1.373822285322555e+05 - [9.686577348568530e+04,1.049379212761591e+05];
function SAET = SAET_cal(gas_node, dead_node, gas_turbine, dead_turbine, ALP)
[~, NGDMASS, ~, ~] = idx_gas_node;
[~, ~, ~, ~, ~, MASSCONSUMPTION, ~] = idx_gas_turbine;
for k=1:length(dead_node)
    [ALP_sort, index] = sort(ALP{k});% 按照ALP_0从小到大排序
    mass_turbine = gas_turbine(dead_turbine{k}(index),MASSCONSUMPTION);
    mass_load = gas_node(dead_node{k},NGDMASS);
    mass_load_sum = sum(mass_load);
    n_failure = length(ALP{k});
    SAET{k} = zeros(1,n_failure);
    SAET{k}(1) = ALP_sort(1)./(mass_load_sum+sum(mass_turbine));
    for i=2:n_failure
        SAET{k}(i) = SAET{k}(i-1) + (ALP_sort(i)-ALP_sort(i-1))./(mass_load_sum+sum(mass_turbine(i:end)));
    end
    [~,index1] = sort(index);% 还原排序
    SAET{k} = SAET{k}(index1);
end