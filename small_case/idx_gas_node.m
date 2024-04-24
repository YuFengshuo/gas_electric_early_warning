function [SERIAL, NGDMASS, PRESSURE, MASSIN] = idx_gas_node
% 结构和参数
SERIAL = 1;% 编号
NGDMASS = 2;% 非燃气轮机负荷流量/(kg/s)
% 运行变量
PRESSURE = 3;% 气压/bar
MASSIN = 4;% 注入流量/(kg/s)
end