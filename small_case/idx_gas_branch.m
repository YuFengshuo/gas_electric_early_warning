function [SERIAL, FROM, TO, COMP, PIPE_L, PIPE_D, MAXMASS, OUTLET_P, MAXSC, MASS] = idx_gas_branch
% 结构和参数
SERIAL = 1;% 编号
FROM = 2;% 初点
TO = 3;% 终点
COMP = 4;% 是否压缩机
PIPE_L = 5;% 管长/km
PIPE_D = 6;% 管径/m
MAXMASS = 7;% 最大流量/(kg/s)
OUTLET_P = 8;% 出口压力/bar
MAXSC = 9;% 最大变比
% 运行变量
MASS = 10;
end