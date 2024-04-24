function [NODE_new, BRANCH_new] = wentai(NODE_IN, BRANCH_IN)
% �ڵ�����
% NODE_NO NODE_TYPE NODE_p(bar) NODE_m(kg/s)
% NODE_TYPE��1-p�� 2-m�� 3-pm��
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
% ֧·����
% BRANCH_NO FROM TO BRANCH_TYPE LENGTH(km) DIAMETER(m) BRANCH_m(kg/s)
% BRANCH_TYPE��1-�ܵ� 2-��ѹ��/ѹ������
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
% ��������
NODE_NO=1;NODE_TYPE=2;NODE_p=3;NODE_m=4;
BRANCH_NO=1;FROM=2;TO=3;BRANCH_TYPE=4;LENGTH=5;DIAMETER=6;BRANCH_m=7;
% ����
c = 310;% ���٣�m/s��
nu = 10.8*10^-6;% �����ȣ�Pa*s��
max_it = 50;% ����������
tol = 1e-9;% �������ֵ
% ���ת��
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
% �õ���������
A = zeros(n,b);
for i=1:b
    A(BRANCH(i,FROM),i) = 1;
    A(BRANCH(i,TO),i) = -1;
end
% �������ͽڵ�ı��
node1 = find(NODE(:,NODE_TYPE)==1);
node2 = find(NODE(:,NODE_TYPE)==2);
node3 = find(NODE(:,NODE_TYPE)==3);
% ��������֧·�ı��
branch1 = find(BRANCH(:,BRANCH_TYPE)==1);
branch2 = find(BRANCH(:,BRANCH_TYPE)==2);
% δ֪��˳��Լ������1��1��ڵ�ע����������2��2��ڵ�ѹ����ƽ������3��1��֧·��������4��2��֧·����
% ����δ֪������Ŀ
num_unknown(1) = size(find(NODE(:,NODE_TYPE)==1),1);
num_unknown(2) = size(find(NODE(:,NODE_TYPE)==2),1);
num_unknown(3) = size(find(BRANCH(:,BRANCH_TYPE)==1),1);
num_unknown(4) = size(find(BRANCH(:,BRANCH_TYPE)==2),1);
% ����˳��Լ������1��KCL����2���ܵ�Լ��
% ���෽����Ŀ
num_equation(1) = n;
num_equation(2) = size(find(BRANCH(:,BRANCH_TYPE)==1),1);
% �ܵ�������
PIPE_l = BRANCH(BRANCH(:,BRANCH_TYPE)==1,LENGTH);% ����
PIPE_d = BRANCH(BRANCH(:,BRANCH_TYPE)==1,DIAMETER);% ֱ��
% ������ʼֵ
m1 = NODE(NODE(:,NODE_TYPE)==1,NODE_m);% 1��ڵ�����
pi2 = NODE(NODE(:,NODE_TYPE)==2,NODE_p).^2;% 2��ڵ�ѹ����ƽ��
mi = BRANCH(BRANCH(:,BRANCH_TYPE)==1,BRANCH_m);% 1��֧·�������ܵ�������
mii = BRANCH(BRANCH(:,BRANCH_TYPE)==2,BRANCH_m);% 2��֧·����
% ��ʼ������NR����
for i=1:max_it
    branch_m = zeros(b,1);
    branch_m([branch1;branch2]) = [mi;mii];% ֧·���������������
    node_m = zeros(n,1);
    node_m([node1;find(NODE(:,NODE_TYPE)~=1)]) = [m1;NODE(NODE(:,NODE_TYPE)~=1,NODE_m)];% �ڵ����������������
    node_pi = zeros(n,1);
    node_pi([node2;find(NODE(:,NODE_TYPE)~=2)]) = [pi2;NODE(NODE(:,NODE_TYPE)~=2,NODE_p).^2];% �ڵ�ѹ����ƽ�������������
    % �ܵ�Ħ��ϵ��
    Re = 4.*abs(mi)./pi./nu./PIPE_d;% ��ŵ��
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
    % �����Ҷ���
    F = zeros(sum(num_equation),1);
    F(1:num_equation(1)) = A*branch_m-node_m;% KCL�������
    F(num_equation(1)+1:end) = A(:,branch1)'*node_pi-16.*lambda.*c.^2/pi^2.*PIPE_l./PIPE_d.^5.*abs(mi).*mi.*10^-7;% �ܵ�Լ���������
    % �����ſɱȾ��󣨷ֿ飩
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
    % ��������
    dx = -inv(J)*F;
    % ���¸�δ֪��
    x = [m1;pi2;mi;mii]+dx;
    m1 = x(1:length(node1));
    pi2 = x(length(node1)+1:length(node1)+length(node2));
    mi = x(length(node1)+length(node2)+1:length(node1)+length(node2)+length(branch1));
    mii = x(length(node1)+length(node2)+length(branch1)+1:end);
    if norm(dx)<tol
        break
    end
end
% �������
NODE_new = NODE_IN;
NODE_new(node1,NODE_m) = m1;
NODE_new(node2,NODE_p) = sqrt(pi2);
BRANCH_new = BRANCH_IN;
BRANCH_new(branch1,BRANCH_m) = mi;
BRANCH_new(branch2,BRANCH_m) = mii;