function [SERIAL, GAS_NODE, ELECTRIC_NODE, RATIO, MINPRESSURE, MASSCONSUMPTION, ACTIVE_POWER, E_SERIAL] = idx_gas_turbine
% 结构和参数
SERIAL = 1;% 编号
GAS_NODE = 2;% 电网节点
ELECTRIC_NODE = 3;% 气网节点
RATIO = 4;% 转换效率/(MW/(kg/s))
MINPRESSURE = 5;% 最小压力/bar
E_SERIAL = 8;
% 运行变量
MASSCONSUMPTION = 6;% 流量/(kg/s)
ACTIVE_POWER = 7;% 有功/MW
end