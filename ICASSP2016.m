% function ICASSP2016(folder, no)
%USAGE
% ICASSP2016('IRC041500','00010');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% doc: https://github.com/baidut/ITS/issues/50
% log:
% 2015-08-02 
% to-do:
% * 
% + 
% -
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 先完成水平线的提取，从而得到车道标记线的参数信息
% 或者选择固定的水平线，计算车道标记宽度值
% 宽度需要有一定的容忍能力

% 为了确保检测精度，不进行resize
% numRow = 150;
% numColumn = 200;
% RGB = imresize(RGB, [numRow, numColumn]);

% 读取某个数据库，某张图片
folder = 'IRC041500';
no = '00010';

folder = ['dataset\roma\', folder];
Orignal = imread([folder, '\IMG', no, '.jpg']);
GroundTruth = imread([folder, '\RIMG', no, '.pgm']);

numRow = size(Orignal, 1);
numColumn = size(Orignal, 2);
horizon = 310; % param.cal

Preprocessed = vvPreprocess(Orignal, horizon); % ROI: [horizon, numRow; 1, numColumn]

% vvRowFilter(Preprocessed, '%TEST'); 
Filtered = vvRowFilter(Preprocessed, 'SMLT'); 
Binary = (Preprocessed-Filtered)>30;
Binary = bwareaopen(Binary, 50); % 滤去孤立点
implot(Orignal, GroundTruth, Preprocessed, Filtered, Preprocessed-Filtered, Binary);

return;

LT = vvGetFeature(Preprocessed, 'LT');
MLT = vvGetFeature(Preprocessed, 'MLT');
MLT = vvGetFeature(Preprocessed, 'SLT');
MLT = vvGetFeature(Preprocessed, 'SMLT');

implot(Orignal, GroundTruth, Preprocessed, LT, MLT, SLT, SMLT);
return;

% 特征提取一步不允许进行假设验证，不能利用高级信息