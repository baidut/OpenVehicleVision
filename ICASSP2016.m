function ICASSP2016(folder, no)
%
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
% ICASSP2016('IRC041500','00010');

folder = ['dataset\roma\', folder];
Orignal = imread([folder, '\IMG', no, '.jpg']);
GroundTruth = imread([folder, '\RIMG', no, '.pgm']);

figure;
implot(Orignal, GroundTruth); 
return;

numRow = size(Orignal, 1);
numColumn = size(Orignal, 2);

%-------------------------------------------------------------------%
function featureExtraction(RGB, method)
% 每一行独立地进行滤波，滤波器的大小跟随透视效应改变
% 使用一维的滤波方式

switch method
case 'LT'

	Filtered_Mean = imfilter(Raw_noisy, [1 1 1; 1 1 1; 1 1 1]/9, 'corr', 'replicate');
case 'SLT'

end