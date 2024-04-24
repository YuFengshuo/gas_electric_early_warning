gas_branch = xlsread('gas_branch1.xlsx');
gas_node = xlsread('gas_node1.xlsx');
gas_source = xlsread('gas_source1.xlsx');
gas_turbine = xlsread('gas_turbine1.xlsx');
n = size(gas_node,1);
b = size(gas_branch,1);
gs = size(gas_source,1);
gt = size(gas_turbine,1);

NODE = zeros(n,4);
NODE(:,1) = gas_node(:,1);
NODE(:,2) = 2;
NODE(:,3) = 10;
NODE(:,4) = -gas_node(:,2);
NODE(gas_source(:,2),2) = 1;
NODE(gas_source(:,2),3) = gas_source(:,3);
for i=1:gt
    NODE(gas_turbine(i,2),4) = NODE(gas_turbine(i,2),4) - gas_turbine(i,6);
end
BRANCH = zeros(b,7);
BRANCH(:,1:3) = gas_branch(:,1:3);
BRANCH(:,4) = 1;
BRANCH(:,5:6) = gas_branch(:,5:6);
BRANCH(:,7) = 1;
[NODE1,BRANCH1] = wentai(NODE,BRANCH);