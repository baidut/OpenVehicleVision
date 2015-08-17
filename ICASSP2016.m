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
% 简单
% folder = 'IRC041500';
% no = '00010';

% 利用颜色特征和未用颜色特征的差别

% folder = 'LRAlargeur13032003';
% no = '02210';
folder = 'BDXD54';
no = '00002';

folder = ['dataset\roma\', folder];
Original = imread([folder, '\IMG', no, '.jpg']);
GroundTruth = imread([folder, '\RIMG', no, '.pgm']);

numRow = size(Original, 1);
numColumn = size(Original, 2);
horizon = 310; % param.cal

RoadRegion = vvGetRoadFace(Original);

% 还原到原图很简单，知道了列的位置，得到占整个列的百分比，
% 再对原来的各行找该位置即可进行验证标定工作

% 需要先进行DLD滤波 采用带掩码的滤波器
mask = ( RoadRegion ~= 0 ); % 没作用 待解决mask_dilate腐蚀一下mask
H = [-1, 0, 1, 0, -1;
     -1, 0, 2, 0, -1;
     -1, 0, 2, 0, -1;
     -1, 0, 2, 0, -1;
     -1, 0, 1, 0, -1];
% 足够长的模板匹配效果较好 5 个像素长度

% 效果较好
% H = [-1, 0, 1, 0, -1;
%      -2, 0, 4, 0, -2;
%      -1, 0, 1, 0, -1];
% RoadFiltered = roifilt2(H,RoadRegion,mask);
% imfilter默认边界为0处理
RoadFiltered = imfilter(RoadRegion,H,'replicate'); % & mask
BW = im2bw( RoadFiltered, graythresh(RoadFiltered) );
% 去除非四邻居连通域
Markings = bwareaopen(BW,18,4);
% 只检测中心的车道标记线？

% 统计每一列的和值
A = sum(Markings, 1);
[maxValue index] = max(A);
ratio = index / size(RoadRegion, 2); % 占的比例
implot(Original, RoadRegion, mask, RoadFiltered, BW, Markings);

% 验证区域，还原车道标记位置到图像中


%三条相互平行间隔相同的线应该可以进行三维重建工作 (假设不成立，车道标记不一定在中间)
% 这样每个点的位置，像素宽度的实际宽度都可以求解出来
% 如果可以再绘制到建模的三维空间里就更强大了
% 根据近视野参数构建3D，再将远视野映射到3D
% 第一次IPM不准确，只是为了车道标记位于一条直线。可以不通过IPM做
% 车和道路方向的夹角没考虑

return;
% ============================================= %

Preprocessed = vvPreprocess(Original, horizon); % ROI: [horizon, numRow; 1, numColumn]

% vvRowFilter(Preprocessed, '%TEST'); 
% Filtered = vvRowFilter(Preprocessed, 'SMLT'); 
% Binary = (Preprocessed-Filtered)>30;
% Binary = bwareaopen(Binary, 50); % 滤去孤立点
% implot(Original, GroundTruth, Preprocessed, Filtered, Preprocessed-Filtered, Binary);

Filtered = vvRowFilter(Preprocessed, 'DLD'); 
implot(Original, GroundTruth, Preprocessed, Filtered);

return;

LT = vvGetFeature(Preprocessed, 'LT');
MLT = vvGetFeature(Preprocessed, 'MLT');
MLT = vvGetFeature(Preprocessed, 'SLT');
MLT = vvGetFeature(Preprocessed, 'SMLT');

implot(Original, GroundTruth, Preprocessed, LT, MLT, SLT, SMLT);
return;


% 需要明确：
% 特征提取一步不允许进行假设验证，不能利用高级信息
% 单个特征肯定效果不好，多特征融合！

% 利用横向的DLD特征和纵向的连贯性
% 人的主观认识：白色，矩形，连贯
% 需要能够自动修补漏洞，去除噪声


% TODO：
% 测试新的模板滤波，寻找跳变边缘特征点并纵向跟踪
% 关键在于抓突变

% 遍历每一行，找突变特征点


% 思路1：先预处理去阴影，思路2：抗阴影的方法 