function [NODE_new, BRANCH_new] = wentai(NODE_IN, BRANCH_IN)
% 节点数据
% NODE_NO NODE_TYPE NODE_p(bar) NODE_m(kg/s)
% NODE_TYPE：1-p点 2-m点 3-pm点
% NODE_IN = [
%     1   1   20  0
%     2   2   20  -2.68
%     3   2   20  -5.98
%     4   2   20  0
%     5   3   15  0
%     6   2   20  -4.98
%     7   2   20  -2.68
%     8   2   20  -2.99
%     ];
% 支路数据
% BRANCH_NO FROM TO BRANCH_TYPE LENGTH(km) DIAMETER(m) BRANCH_m(kg/s)
% BRANCH_TYPE：1-管道 2-调压阀/压缩机等
% BRANCH_IN = [
%     1   1   2   1   12  0.6   1
%     2   2   3   1   9   0.3   1
%     3   2   4   1   8   0.3   1
%     4   4   3   1   7   0.3   1
%     5   5   6   1   15  0.6   1
%     6   6   7   1   7   0.3   1
%     7   6   8   1   9   0.3   1
%     8   4   5   2   0   0     1
%     ];
% 建立索引
NODE_NO=1;NODE_TYPE=2;NODE_p=3;NODE_m=4;
BRANCH_NO=1;FROM=2;TO=3;BRANCH_TYPE=4;LENGTH=5;DIAMETER=6;BRANCH_m=7;
% 常数
c = 310;% 声速（m/s）
nu = 10.8*10^-6;% 动力黏度（Pa*s）
max_it = 50;% 迭代最大次数
tol = 1e-9;% 误差允许值
% 序号转换
n = size(NODE_IN,1);
b = size(BRANCH_IN,1);
node_no = NODE_IN(:,NODE_NO);
NODE = NODE_IN;
NODE(:,NODE_NO) = 1:n;
BRANCH = BRANCH_IN;
BRANCH(:,BRANCH_NO) = 1:b;
for i=1:b
    BRANCH(i,FROM) = find(node_no==BRANCH_IN(i,FROM));
    BRANCH(i,TO) = find(node_no==BRANCH_IN(i,TO));
end
% 得到关联矩阵
A = zeros(n,b);
for i=1:b
    A(BRANCH(i,FROM),i) = 1;
    A(BRANCH(i,TO),i) = -1;
end
% 各种类型节点的编号
node1 = find(NODE(:,NODE_TYPE)==1);
node2 = find(NODE(:,NODE_TYPE)==2);
node3 = find(NODE(:,NODE_TYPE)==3);
% 各种类型支路的编号
branch1 = find(BRANCH(:,BRANCH_TYPE)==1);
branch2 = find(BRANCH(:,BRANCH_TYPE)==2);
% 未知量顺序约定：（1）1类节点注入流量；（2）2类节点压力的平方；（3）1类支路流量；（4）2类支路流量
% 各类未知量的数目
num_unknown(1) = size(find(NODE(:,NODE_TYPE)==1),1);
num_unknown(2) = size(find(NODE(:,NODE_TYPE)==2),1);
num_unknown(3) = size(find(BRANCH(:,BRANCH_TYPE)==1),1);
num_unknown(4) = size(find(BRANCH(:,BRANCH_TYPE)==2),1);
% 方程顺序约定：（1）KCL；（2）管道约束
% 各类方程数目
num_equation(1) = n;
num_equation(2) = size(find(BRANCH(:,BRANCH_TYPE)==1),1);
% 管道各参数
PIPE_l = BRANCH(BRANCH(:,BRANCH_TYPE)==1,LENGTH);% 长度
PIPE_d = BRANCH(BRANCH(:,BRANCH_TYPE)==1,DIAMETER);% 直径
% 迭代初始值
m1 = NODE(NODE(:,NODE_TYPE)==1,NODE_m);% 1类节点流量
pi2 = NODE(NODE(:,NODE_TYPE)==2,NODE_p).^2;% 2类节点压力的平方
mi = BRANCH(BRANCH(:,BRANCH_TYPE)==1,BRANCH_m);% 1类支路流量（管道流量）
mii = BRANCH(BRANCH(:,BRANCH_TYPE)==2,BRANCH_m);% 2类支路流量
% 开始迭代（NR法）
for i=1:max_it
    branch_m = zeros(b,1);
    branch_m([branch1;branch2]) = [mi;mii];% 支路流量，按序号排列
    node_m = zeros(n,1);
    node_m([node1;find(NODE(:,NODE_TYPE)~=1)]) = [m1;NODE(NODE(:,NODE_TYPE)~=1,NODE_m)];% 节点流量，按序号排列
    node_pi = zeros(n,1);
    node_pi([node2;find(NODE(:,NODE_TYPE)~=2)]) = [pi2;NODE(NODE(:,NODE_TYPE)~=2,NODE_p).^2];% 节点压力的平方，按序号排列
    % 管道摩擦系数
    Re = 4.*abs(mi)./pi./nu./PIPE_d;% 雷诺数
    lambda = zeros(length(Re),1);
    for j=1:length(Re)
        if Re(j)==0
            lambda(j) = 100000;
        elseif Re(j)>0 && Re(j)<=2100
            lambda(j) = 64/Re(j);
        elseif Re(j)>2100 && Re(j)<=3500
            lambda(j) = 0.03 + (Re(j)-2100)/(65*Re(j)-10^5);
        else
            lambda(j) = 0.11*(0.15/(PIPE_d(j)*1000)+68/Re(j))^0.25;
        end
    end
    % 计算右端项
    F = zeros(sum(num_equation),1);
    F(1:num_equation(1)) = A*branch_m-node_m;% KCL方程左侧
    F(num_equation(1)+1:end) = A(:,branch1)'*node_pi-16.*lambda.*c.^2/pi^2.*PIPE_l./PIPE_d.^5.*abs(mi).*mi.*10^-7;% 管道约束方程左侧
    % 计算雅可比矩阵（分块）
    KCL_m1 = zeros(n,length(node1));
    for j=1:length(node1)
        KCL_m1(node1(j),j) = -1;
    end
    KCL_pi2 = zeros(n,length(node2));
    KCL_mi = A(:,branch1);
    KCL_mii = A(:,branch2);
    PIPE_m1 = zeros(length(branch1),length(node1));
    PIPE_pi2 = A(node2,branch1)';
    PIPE_mi = diag(-32.*c.^2./pi.^2./PIPE_d.^5.*PIPE_l.*10^-7.*abs(mi).*lambda);
    PIPE_mii = zeros(length(branch1),length(branch2));
    J = [KCL_m1,KCL_pi2,KCL_mi,KCL_mii;PIPE_m1,PIPE_pi2,PIPE_mi,PIPE_mii];
    % 求解误差量
    dx = -inv(J)*F;
    % 更新各未知量
    x = [m1;pi2;mi;mii]+dx;
    m1 = x(1:length(node1));
    pi2 = x(length(node1)+1:length(node1)+length(node2));
    mi = x(length(node1)+length(node2)+1:length(node1)+length(node2)+length(branch1));
    mii = x(length(node1)+length(node2)+length(branch1)+1:end);
    if norm(dx)<tol
        break
    end
end
% 结果整理
NODE_new = NODE_IN;
NODE_new(node1,NODE_m) = m1;
NODE_new(node2,NODE_p) = sqrt(pi2);
BRANCH_new = BRANCH_IN;
BRANCH_new(branch1,BRANCH_m) = mi;
BRANCH_new(branch2,BRANCH_m) = mii;