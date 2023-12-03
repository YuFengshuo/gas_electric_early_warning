% gas_branch = xlsread('gas_branch.xlsx');
% gas_node = xlsread('gas_node.xlsx');
% gas_source = xlsread('gas_source.xlsx');
% gas_turbine = xlsread('gas_turbine.xlsx');
% failure_source = 1;
% failure_pipeline = [1,3];
function [dead_node, dead_branch, dead_turbine] = topologize...
    (gas_node, gas_branch, gas_source, gas_turbine, failure_source, failure_pipeline)
% 拓扑分析，输出没有气源的死岛；故障种类：0代表气源故障，1代表支路故障
[~, ~, ~, ~] = idx_gas_node;
[~, FROM, TO, ~, ~, ~, ~, ~, ~] = idx_gas_branch;
[~, NODE, ~] = idx_gas_source;
[SERIAL, GAS_NODE, ~, ~, ~, ~, ~] = idx_gas_turbine;
% 设置故障
gas_source(failure_source,NODE) = 0;
N = size(gas_node,1);
b = size(gas_branch,1);
gas_A = zeros(N,b);
for i=1:b
    gas_A(gas_branch(i,FROM),i) = 1;
    gas_A(gas_branch(i,TO),i) = -1;
end
gas_A(:,failure_pipeline) = [];
[groups, unvisited] = connected_components(gas_A');
% 找到失去气源的节点
dead_node = {};
for i=1:length(groups)
    source_judge = ismember(gas_source(:,NODE)',groups{i});
    if source_judge==0 %一个数组等于零是指全为零
        dead_node = [dead_node, groups{i}];
    end
end
for i=1:length(unvisited)
    source_judge = ismember(gas_source(:,NODE)',unvisited(i));
    if source_judge==0
        dead_node = [dead_node, unvisited(i)];
    end
end
% 逐一检查管道，如果在 dead_node 上，则标记
dead_branch = cell(1,length(dead_node));
for k=1:length(dead_node)
    j = 1;
    for i=1:b
        if ismember(gas_branch(i,FROM),dead_node{k})&&ismember(gas_branch(i,TO),dead_node{k})
            dead_branch{k}(j) = gas_branch(i,SERIAL);
            j = j + 1;
        end
    end
end
% 逐一检查燃气机组，如果在 dead_node 上，则标记
dead_turbine = cell(1,length(dead_node));
for k=1:length(dead_node)
    j = 1;
    for i=1:size(gas_turbine,1)
        if ismember(gas_turbine(i,GAS_NODE),dead_node{k})
            dead_turbine{k}(j) = gas_turbine(i,SERIAL);
            j = j + 1;
        end
    end
end