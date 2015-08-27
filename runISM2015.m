% 测试论文ISM2015，生成论文中的图片

global doimdump;

p = genpath([cd, '\dataset\roma\']);
addpath(p);

% 基本流程
doimdump = true; % 输出中间图片
ISM2015('BDXD54\IMG00002.jpg'); 			

return;

% 典型图片测试
doimdump = false; % 不输出中间图片
ISM2015('BDXD54\IMG00071.jpg'); 			print('expT1.eps','-depsc'); % 大面积强阴影
ISM2015('LRAlargeur26032003\IMG00579.jpg'); print('expT2.eps','-depsc'); % 弱阴影
ISM2015('LRAlargeur13032003\IMG02210.jpg'); print('expT3.eps','-depsc'); % 大量弱阴影
ISM2015('BDXD54\IMG00030.jpg'); 			print('expT4.eps','-depsc'); % 多阴影
ISM2015('LRAlargeur13032003\IMG00919.jpg'); print('expT5.eps','-depsc'); % 路面有水
ISM2015('LRAlargeur13032003\IMG02175.jpg'); print('expT6.eps','-depsc'); % 高光

% 方法的局限性：不适合大弯道
ISM2015('LRAlargeur13032003\IMG02330.jpg'); print('expF1.eps','-depsc'); % 十字路
ISM2015('LRAlargeur13032003\IMG00858.jpg'); print('expF2.eps','-depsc'); % 分岔路


% 非典型，不在论文中
% ISM2015('LRAlargeur13032003\IMG00005.jpg'); print('exp06.eps','-depsc');
% ISM2015('LRAlargeur13032003\IMG01070.jpg'); print('exp08.eps','-depsc'); % 大量阴影
% ISM2015('LRAlargeur13032003\IMG00878.jpg'); print('expf1.eps','-depsc'); % 大弯道 多车道标记
% 待解决
% ISM2015('LRAlargeur13032003\IMG01771.jpg'); print('expf1.eps','-depsc'); % 十字
% ISM2015('BDXD54\IMG00146.jpg'); 			print('exp17.eps','-depsc'); % 单侧强阴影 在新的论文中解决
% ISM2015('BDXD54\IMG00164.jpg'); 			print('exp14.eps','-depsc'); % 高光
% ISM2015('LRAlargeur14062002\IMG00951.jpg'); print('exp18','-depsc'); % 较暗
% ISM2015('RouenN8IRC052310\IMG00915.jpg'); 	print('exp19','-depsc'); % 弯道
% ISM2015('RouenN8IRC052310\IMG00223.jpg'); 	print('exp20','-depsc'); % 没有草覆盖

% 单边没有提取到的情形的鲁棒性 LRAlargeur13032003\IMG02123
% 没有车道线 LRAlargeur13032003\IMG02123
% ISM2015('LRAlargeur14062002\IMG00002.jpg'); print('exp15.eps','-depsc'); % 高光 多个车道线，错检为其他的
% ISM2015('LRAlargeur13032003\IMG00576.jpg'); print('exp7 ','-depsc'); % 待修复
% ISM2015('LRAlargeur13032003\IMG01771.jpg'); print('exp9 ','-depsc'); % 分岔口
% ISM2015('LRAlargeur26032003\IMG01542.jpg'); print('exp10','-depsc'); % 分岔口 弯道
% ISM2015('LRAlargeur13032003\IMG01362.jpg'); print('exp11','-depsc'); % 分岔口

% 整个数据集测试，输出结果

% 存在的问题遗留着，以后的论文说明改进
% 单边的改进，多车道线，普通道路