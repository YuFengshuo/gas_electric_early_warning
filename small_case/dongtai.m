%% ��Ȼ��ϵͳ��̬������ǰ��������Ϊ��ʼ����������������Ϊ�߽��������̶���
function [node_p, node_m, pipe_0, valve_m] = dongtai(NODE_steady, BRANCH_steady, NODE_boundary, dx, dt, iter)
% % ��̬������
% NODE_steady = [
%     1   1   70      99.64
%     2   2   53.92  -99.64
%     ];
% BRANCH_steady = [
%     1   1   2   1   60  0.6 99.64
%     ];
% % ��̬����ı߽�����
% NODE_boundary = [
%     1   1   70  99.64
%     2   2   70  -103.62
%     ];
% ��������
NODE_NO=1;NODE_TYPE=2;NODE_p=3;NODE_m=4;
BRANCH_NO=1;FROM=2;TO=3;BRANCH_TYPE=4;LENGTH=5;DIAMETER=6;BRANCH_m=7;
% ���±��
n = size(NODE_steady,1);
b = size(BRANCH_steady,1);
node_no = NODE_steady(:,NODE_NO);
NODE = NODE_steady;
NODE(:,NODE_NO) = 1:n;
NODE_new = NODE_boundary;
NODE_new(:,NODE_NO) = 1:n;
BRANCH = BRANCH_steady;
BRANCH(:,BRANCH_NO) = 1:b;
for i=1:b
    BRANCH(i,FROM) = find(node_no==BRANCH_steady(i,FROM));
    BRANCH(i,TO) = find(node_no==BRANCH_steady(i,TO));
end
% �������ͽڵ�ı��
node1 = find(NODE_new(:,NODE_TYPE)==1);
node2 = find(NODE_new(:,NODE_TYPE)==2);
node3 = find(NODE_new(:,NODE_TYPE)==3);
% ��������֧·�ı��
branch1 = find(BRANCH(:,BRANCH_TYPE)==1);
branch2 = find(BRANCH(:,BRANCH_TYPE)==2);
% �ܵ�������
PIPE_l = BRANCH(BRANCH(:,BRANCH_TYPE)==1,LENGTH);% ����/km
PIPE_d = BRANCH(BRANCH(:,BRANCH_TYPE)==1,DIAMETER);% ֱ��/m
% �õ���������
n = size(NODE,1);
b = size(BRANCH,1);
A = zeros(n,b);
for i=1:b
    A(BRANCH(i,FROM),i) = 1;
    A(BRANCH(i,TO),i) = -1;
end
A_pipe = A(:,branch1);
A_valve = A(:,branch2);
% �ռ���ɢ������ȡ�ܵ�ѹ������������
pipe_0 = cell(length(branch1),2);% ��һ��ѹ�����ڶ�������
N = ceil(PIPE_l./dx);% �ָ���
for i=1:length(branch1)
    pipe_0{i,1} = zeros(N(i)+1,1);
    for j=1:N(i)+1
        pipe_0{i,1}(j) = sqrt(NODE(BRANCH(branch1(i),FROM),NODE_p).^2 +...
            (j-1)./N(i).*(NODE(BRANCH(branch1(i),TO),NODE_p).^2-...
            NODE(BRANCH(branch1(i),FROM),NODE_p).^2));
    end
    pipe_0{i,2} = ones(N(i),1).*BRANCH(branch1(i),BRANCH_m);
end
valve_m = BRANCH(branch2,BRANCH_m);
node_p = NODE(:, NODE_p);
node_m = NODE(:, NODE_m);
% ����
c = 300;% ���٣�m/s��
nu = 10.8*10^-6;% �ȣ�Pa*s��
max_it = iter;% ����������
delta_x = PIPE_l./N;
delta_t = dt;% ��s��
% ���ܵ��ĵ�λ��������
L_0 = 1./(pi*PIPE_d.^2/4);
% ���ܵ��ĵ�λ��������
C_0 = 1./(L_0.*c^2);
% �ڵ�����������Խڵ�iΪ���Ĺܵ����Խڵ�iΪ�յ�Ĺܵ����Խڵ�iΪ���ķ��š��Խڵ�iΪ�յ�ķ��ţ�
node_details = cell(n, 4);
for i=1:n
    node_details{i,1} = find(A_pipe(i,:)==1);
    node_details{i,2} = find(A_pipe(i,:)==-1);
    node_details{i,3} = find(A_valve(i,:)==1);
    node_details{i,4} = find(A_valve(i,:)==-1);
end
% �ܵ�����������Թܵ�i���Ϊ���Ĺܵ����Թܵ�i���Ϊ�յ�Ĺܵ����Թܵ�i�յ�Ϊ���Ĺܵ����Թܵ�i�յ�Ϊ�յ�Ĺܵ�...��
pipe_details = cell(length(branch1),10);
for i=1:length(branch1)
    pipe_details{i,1} = find(A_pipe(BRANCH(branch1(i),FROM),:)==1);
    pipe_details{i,2} = find(A_pipe(BRANCH(branch1(i),FROM),:)==-1);
    pipe_details{i,3} = find(A_pipe(BRANCH(branch1(i),TO),:)==1);
    pipe_details{i,4} = find(A_pipe(BRANCH(branch1(i),TO),:)==-1);
    pipe_details{i,5} = find(A_valve(BRANCH(branch1(i),FROM),:)==1);
    pipe_details{i,6} = find(A_valve(BRANCH(branch1(i),FROM),:)==-1);
    pipe_details{i,7} = find(A_valve(BRANCH(branch1(i),TO),:)==1);
    pipe_details{i,8} = find(A_valve(BRANCH(branch1(i),TO),:)==-1);
    pipe_details{i,9} = 0;% �ܵ������������
    pipe_details{i,10} = 0;% �ܵ����յ�������
    for j=pipe_details{i,1}
        pipe_details{i,9} = pipe_details{i,9} + C_0(j)*delta_x(j)/2*10^3;
    end
    for j=pipe_details{i,2}
        pipe_details{i,9} = pipe_details{i,9} + C_0(j)*delta_x(j)/2*10^3;
    end
    for j=pipe_details{i,3}
        pipe_details{i,10} = pipe_details{i,10} + C_0(j)*delta_x(j)/2*10^3;
    end
    for j=pipe_details{i,4}
        pipe_details{i,10} = pipe_details{i,10} + C_0(j)*delta_x(j)/2*10^3;
    end
end
% ��������������Է������Ϊ���Ĺܵ����Է������Ϊ�յ�Ĺܵ�...��
valve_details = cell(length(branch2),2);
for i=1:length(branch2)
    valve_details{i,1} = find(A_pipe(BRANCH(branch2(i),FROM),:)==1);
    valve_details{i,2} = find(A_pipe(BRANCH(branch2(i),FROM),:)==-1);
    valve_details{i,3} = find(A_pipe(BRANCH(branch2(i),TO),:)==1);
    valve_details{i,4} = find(A_pipe(BRANCH(branch2(i),TO),:)==-1);
    valve_details{i,5} = find(A_valve(BRANCH(branch2(i),FROM),:)==1);
    valve_details{i,6} = find(A_valve(BRANCH(branch2(i),FROM),:)==-1);
    valve_details{i,7} = find(A_valve(BRANCH(branch2(i),TO),:)==1);
    valve_details{i,8} = find(A_valve(BRANCH(branch2(i),TO),:)==-1);
end
% ��ʼ����
for k=1:max_it
    % ��m�㵥λ��������
    % Ħ��ϵ��
    lambda = cell(length(branch1),1);
    for i=1:length(branch1)
        m_temp = pipe_0{i,2}(:,k);
        Re = 4.*abs(m_temp)./pi./nu./PIPE_d(i);% ��ŵ��
        lambda{i} = zeros(length(Re),1);
        for j=1:length(Re)
            if Re(j)==0
                lambda{i}(j) = 100000;
            elseif Re(j)>0 && Re(j)<=2100
                lambda{i}(j) = 64/Re(j);
            elseif Re(j)>2100 && Re(j)<=3500
                lambda{i}(j) = 0.03 + (Re(j)-2100)/(65*Re(j)-10^5);
            else
                lambda{i}(j) = 0.11*(0.15/(PIPE_d(i)*1000)+68/Re(j))^0.25;
            end
        end
    end
    % m��ѹ�������ƣ�
    p_m = cell(length(branch1),1);
    for i=1:length(branch1)
        p_temp = pipe_0{i,1}(:,k);
        p_m{i} = zeros(length(p_temp)-1,1);
        for j=1:length(p_temp)-1
            p_m{i}(j) = (p_temp(j)+p_temp(j+1))/2;
        end
    end
    % m������
    v_m = cell(length(branch1),1);
    for i=1:length(branch1)
        m_temp = pipe_0{i,2}(:,k);
        v_m{i} = zeros(length(m_temp),1);
        for j=1:length(m_temp)
            v_m{i}(j) = m_temp(j)*c^2*L_0(i)/p_m{i}(j)/10^5;
        end
    end
    % ��R_0
    R_0 = cell(length(branch1),1);
    for i=1:length(branch1)
        R_0{i} = lambda{i}.*abs(v_m{i})./2.*L_0(i)./PIPE_d(i);
    end
    % ����p��
    for i=1:length(branch1)
        % �ܵ����
        if ismember(NODE_new(BRANCH(branch1(i),FROM),NODE_TYPE),[1,3])
            pipe_0{i,1}(1,k+1) = NODE_new(BRANCH(branch1(i),FROM),NODE_p);
        else
            m_in_node = node_m(BRANCH(branch1(i),FROM),k);
            for j=pipe_details{i,1}
                m_in_node = m_in_node - pipe_0{j,2}(1,k);
            end
            for j=pipe_details{i,2}
                m_in_node = m_in_node + pipe_0{j,2}(end,k);
            end
            for j=pipe_details{i,5}
                m_in_node = m_in_node - valve_m(j,k);
            end
            for j=pipe_details{i,6}
                m_in_node = m_in_node + valve_m(j,k);
            end
            pipe_0{i,1}(1,k+1) = pipe_0{i,1}(1,k) + m_in_node*delta_t/...
                pipe_details{i,9}/10^5;
        end
        % �ܵ��յ�
        if ismember(NODE_new(BRANCH(branch1(i),TO),NODE_TYPE),[1,3])
            pipe_0{i,1}(end,k+1) = NODE_new(BRANCH(branch1(i),TO),NODE_p);
        else
            m_in_node = node_m(BRANCH(branch1(i),TO),k);
            for j=pipe_details{i,3}
                m_in_node = m_in_node - pipe_0{j,2}(1,k);
            end
            for j=pipe_details{i,4}
                m_in_node = m_in_node + pipe_0{j,2}(end,k);
            end
            for j=pipe_details{i,7}
                m_in_node = m_in_node - valve_m(j,k);
            end
            for j=pipe_details{i,8}
                m_in_node = m_in_node + valve_m(j,k);
            end
            pipe_0{i,1}(end,k+1) = pipe_0{i,1}(end,k) + ...
                m_in_node*delta_t/pipe_details{i,10}/10^5;
        end
        % �ܵ��м��
        for j=2:size(pipe_0{i,1},1)-1
            pipe_0{i,1}(j,k+1) = pipe_0{i,1}(j,k) + ...
                (pipe_0{i,2}(j-1,k)-pipe_0{i,2}(j,k))*delta_t/C_0(i)/10^5/delta_x(i)/10^3;
        end
    end
    % ������ڵ�ѹ��
    for i=1:length(branch1)
        node_p(BRANCH(branch1(i),FROM),k+1) = pipe_0{i,1}(1,k+1);
        node_p(BRANCH(branch1(i),TO),k+1) = pipe_0{i,1}(end,k+1);
    end
    % ����m��
    % �ܵ��м��
    for i=1:length(branch1)
        for j=1:size(pipe_0{i,2},1)
            pipe_0{i,2}(j,k+1) = (1-R_0{i}(j)/L_0(i)*delta_t)*pipe_0{i,2}(j,k) + ...
                (pipe_0{i,1}(j,k+1)-pipe_0{i,1}(j+1,k+1))*10^5*delta_t/L_0(i)/delta_x(i)/10^3;
        end
    end
    % �ڵ�
    for i=1:n
        if NODE_new(i,NODE_TYPE)==1
            node_m(i,k+1) = 0;
            for j=node_details{i,1}
                node_m(i,k+1) = node_m(i,k+1) + pipe_0{j,2}(1,k+1);
            end
            for j=node_details{i,2}
                node_m(i,k+1) = node_m(i,k+1) - pipe_0{j,2}(end,k+1);
            end
        else
            node_m(i,k+1) = NODE_new(i,NODE_m);
        end
    end
    % ��ѹ��
    for i=1:length(branch2)
        valve_m(i,k+1) = -node_m(BRANCH(branch2(i),TO));
        for j=valve_details{i,3}
            valve_m(i,k+1) = valve_m(i,k+1) + pipe_0{j,2}(1,k+1);
        end
        for j=valve_details{i,4}
            valve_m(i,k+1) = valve_m(i,k+1) - pipe_0{j,2}(end,k+1);
        end
    end
end