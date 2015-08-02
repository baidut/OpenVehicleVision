function SKY = imshowsky(RGB)
% RGB = 'dataset\roma\BDXD54\IMG00002.jpg';
% RGB = 'dataset\roma\LRAlargeur26032003\IMG00579.jpg';
% RGB = 'dataset\IMG03326.jpg'; % 干净的例子，论文中用
% RGB = 'dataset\IMG00002_ll_s_paper.jpg'; %这个也行！！论文中用
% RGB = 'dataset\IMG02210_s_paper.jpg';
% RGB = 'dataset\IMG00164_paper.jpg';
% RGB = 'dataset\IMG00030_s_paper.jpg';
%IMSHOWCOLOR show the color channels of an image. 
% USAGE:
% TEST IMAGE:
% 之后就是采用横轴统计进行区域选择，消失点，地平线的检测
% TODO：getChannel改为子函数，支持更多颜色空间
% help rgb2[tab]
% ----------------------------
% s - shadowy 有物体的投影
% ss - more shadowy
% S - 大面积投影
% n - noise 其他噪声
% l - lu 有高亮的区域
% ll - 光照严重不均衡
% c - clean

% IMG00164_paper 
% ----------------------------

% 新想法： 阴影的颜色值是物体颜色值在某个空间的shift，考察这个shift可以还原
close all;
if isstr(RGB)
	RGB = imread(RGB);
end

height = 150;
width = 200;
% RGB = imresize(RGB, [300, 400]);
RGB = imresize(RGB, [height, width]);

[RGB_R, 	RGB_G, 		RGB_B	] = getChannel(RGB);

% 调整对比度，防止整体偏亮或者偏暗的情形 
% % 对各通道进行直方图均衡化（基于统计信息，处理后图像不自然平滑，产生大量噪点）
% RGB_R = histeq(RGB_R);
% RGB_G = histeq(RGB_G);
% RGB_B = histeq(RGB_B);
% RGB = cat(3, RGB_R, RGB_G, RGB_B);

[HSV_H, 	HSV_S, 		HSV_V	] = getChannel(rgb2hsv(RGB));

% 饱和度计算（对比HSV_S看不出区别）
% 最大值为0时，000全黑的点饱和度为0
% RGB_MAX = RGB_MIN 时， 饱和度为0
RGB_MIN = min(min(RGB_R, RGB_G) , RGB_B);
RGB_MAX = max(max(RGB_R, RGB_G) , RGB_B);
RGB_MAX_NO_ZERO = RGB_MAX;
RGB_MAX_NO_ZERO(RGB_MAX_NO_ZERO == 0) = 1;
Saturate = double(RGB_MAX - RGB_MIN) ./ double(RGB_MAX_NO_ZERO) ;

% 发现阴影的B分量偏高 这里的阴影是高光造成的深影，饱和度高
Shadowness = double(RGB_B - RGB_MIN) ./ double(RGB_MAX + 1); % Shadow = (RGB_MAX == RGB_B) & (RGB_MAX < 80); % 较准确
Treeness = double(abs(RGB_MAX - RGB_B)) ./ double(RGB_MAX + 1);

Tree = Treeness > 0.3; % 0.2 % 用histeq和graythresh效果不好
Tree = imclose(Tree, strel('square',3));% Tree = imdilate(Tree, strel('square',3));imclose imopen
Tree = bwareaopen(Tree, 50); % 车道线也去除掉
% Tree = imdilate(Tree, strel('square',3));
% 注意图像的点可能会因为显示大小问题而不显示 图像不赋初值，大小可能出错
Boundary = zeros(size(Tree));
Boundary_True = zeros(size(Tree));
mid = size(Tree, 2)/2;
last_r = size(Tree, 1);
left = 1;
for c = 1 : size(Tree, 2)
	for r = size(Tree, 1) : -1 : 1
		if 1 == Tree(r, c)
			Boundary(r, c) = 1;
			break;
		end
	end
end 

for r = size(Tree, 1) : -1 : 1
	for c = mid : size(Tree, 2)
		if 1 == Tree(r, c)
			Boundary_True(r, c) = 1;
			break;
		end
	end
	for c = mid : -1 : 1
		if 1 == Tree(r, c)
			Boundary_True(r, c) = 1;
			break;
		end
	end
end
Boundary_True = Boundary_True & Boundary;
% 从中间向两边找效果不好
% 任务： 画出路面区域
% 换种方法直线拟合 标注出区域
Lines = RGB;
figure; implot(RGB, Treeness, Tree, Boundary, Boundary_True, Lines);
% 先画点
hold on
for c = 1 : size(Tree, 2)
	for r = size(Tree, 1) : -1 : 1
		if 1 == Boundary_True(r, c)
			plot(c, r, '+');
			break;
		end
	end
end 

% 区分左右车道线
% 可能没找到
% BoudaryLine_left = detectline(Boundary_True, [-80:0]);
% BoudaryLine_right = detectline(Boundary_True, [0:80]);
lines = detectline(Boundary_True, [-89:89]); % 防止漏检测
if length(lines) < 1
	error('no line found!');
end 

if length(lines) == 2
	BoudaryLine_left = lines(1);
	BoudaryLine_right = lines(2);
else 
	BoudaryLine_left = lines(1);
	plotline(BoudaryLine_left.point1, BoudaryLine_left.point2,'LineWidth',5,'Color','red');
	return;
end 

if isempty(BoudaryLine_left) && isempty(BoudaryLine_right)
	error('no line found!');
end

if isempty(BoudaryLine_left)
	plotline(BoudaryLine_right.point1, BoudaryLine_right.point2,'LineWidth',5,'Color','red');
	return;
end 

if isempty(BoudaryLine_right)
	plotline(BoudaryLine_left.point1, BoudaryLine_left.point2,'LineWidth',5,'Color','red');
	return;
end 

% 两个直线可能相同，相同后交点就求不出来了
theta1 = lines(1).theta;
theta2 = lines(2).theta;

% 画消失点 圆圈o
vanishPoint = linemeetpoint( BoudaryLine_left.point1,BoudaryLine_left.point2,BoudaryLine_right(1).point1, BoudaryLine_right.point2 ); 

% plot
hold on;
plot(vanishPoint(1), vanishPoint(2), 'ro');
% 水平线horison  把消失点所在的水平位置设为地平线
plotline([1, vanishPoint(2)], [size(Tree, 2), vanishPoint(2)], 'LineWidth',1,'Color','blue');
endPoint1 = linemeetpoint( BoudaryLine_left.point1, BoudaryLine_left.point2, [1, size(Tree, 1)], [4, size(Tree, 1)]); % 注意坐标反的 试试plot(1, 5, 'b*');
endPoint2 = linemeetpoint( BoudaryLine_right.point1, BoudaryLine_right.point2, [1, size(Tree, 1)], [4, size(Tree, 1)]);
plot(endPoint1(1), endPoint1(2), 'r*');
plot(endPoint2(1), endPoint2(2), 'r*');

plotline(vanishPoint, endPoint1,'LineWidth',1,'Color','yellow');
plotline(vanishPoint, endPoint2,'LineWidth',1,'Color','yellow');

% 第二步，车道线特征提取
% ROI设置 截取地平线以下的部分 简单地取地平线以下的部分
horison = floor(vanishPoint(2)); % 有可能horison为负数 特殊图片
ROI = RGB(horison:end,:,:);

% 根据
% 只检测路面区域内的 计算左右点
% RGB_MEAN 不包含RGB_B RGB_MIN MEAN 效果很差

V_ROI = double(HSV_V(horison:end,:));% V_ROI = HSV_V(horison:end,:); 注意修改了
S_ROI = HSV_S(horison:end,:);
[h, w] = size(V_ROI);

DLD = zeros(h, w);
DLD_improved = zeros(h, w);

end1 = min(endPoint2(1), endPoint1(1));
end2 = max(endPoint2(1), endPoint1(1));

% 进一步地，仅在路面区域内进行求解
for r = 1 : h % size(Tree, 1) : -1 : (horison-1)
	mw = ceil(5 * r / h);% marking width
	
	left = ceil( vanishPoint(1) - (vanishPoint(1) - end1)* r / h);
	right = ceil( vanishPoint(1) + (end2 - vanishPoint(1))* r / h);
	left = max(1, left);
	right = min(right, w);
	
	for c = (mw+left) : (right - mw )
	% 直接采用该公式的效果不好，改成添加饱和度 可以过滤掉阴影
	% DLD_improved = 
	% DLD 是大于左边一定范围且大于右边一定范围
		% DLD(r, c) = 2* V_ROI(r, c) - (V_ROI(r , c - mw)+V_ROI(r , c + mw)) - abs(V_ROI(r , c - mw) - V_ROI(r , c + mw));
		
		DLD(r, c) = (V_ROI(r, c) - max(V_ROI(r , c - mw), V_ROI(r , c + mw)))  ./ (V_ROI(r , c - mw)+V_ROI(r , c + mw)) ;
		% DLD(r, c) = (1-S_ROI(r, c))*V_ROI(r, c) ./ (V_ROI(r , c - mw)+V_ROI(r , c + mw));
		DLD_improved(r, c) = V_ROI(r, c) ./ (V_ROI(r , c - mw)+V_ROI(r , c + mw));
		% 考虑对称性反而不好，考虑饱和度也不好，题目变化？
		% DLD_S(r, c) = 2* S_ROI(r, c) - (S_ROI(r , c - mw)+S_ROI(r , c + mw)) - abs(S_ROI(r , c - mw) - S_ROI(r , c + mw));
		% k = min(V_ROI(r , c - mw), V_ROI(r , c + mw)) ./ max(V_ROI(r , c - mw), V_ROI(r , c + mw));
		% DLD_improved(r, c) = k * DLD(r, c);
		% - 2*S_ROI(r, c);
	end
end 

% 迭代的意义不大
% DLD1 = filterDLD(HSV_V(horison:end,:));
% DLD2 = filterDLD(DLD1);

% 归一化
DLD = mat2gray(DLD);
DLD_improved = mat2gray(DLD_improved);
Marking = (DLD_improved>0.48); % 0.7
% Marking = imclose(Marking, strel('square',3)); % imopen
Marking = bwareaopen(Marking, 35);
% 改进 取中点 
% ------------------------------------

% 检测直线的范围确定
lines = detectline(Marking, [ceil(min(theta1, theta2)):floor(max(theta1, theta2))]); % 防止漏检测

MarkingLine = lines(1);

% close all;
imwrite(ROI, 'results/ROI.jpg');
imwrite(DLD_improved, 'results/DLD.jpg');


RGB_Marked = RGB;

% horizon!!! 拼写错误
% for c = 1 : width
	% for r =  horison : height
		% if 1 == Marking(r +1 -horison, c)
			% RGB_Marked(r, c, 1) = 0;
			% RGB_Marked(r, c, 2) = 255;
			% RGB_Marked(r, c, 3) = 0;
		% end
	% end
% end 
figure;imshow(RGB_Marked);

startPoint3 = linemeetpoint( MarkingLine.point1, MarkingLine.point2, [1, 0], [4, 0]); 

endPoint3 = linemeetpoint( MarkingLine.point1, MarkingLine.point2, [1, size(Tree, 1)], [4, size(Tree, 1)]); % 注意坐标反的 试试plot(1, 5, 'b*');
endPoint3(2) = endPoint3(2) + horison;
startPoint3(2) = startPoint3(2) + horison;

% plotline(vanishPoint, endPoint3,'LineWidth',3,'Color','green');
plotline(startPoint3, endPoint3,'LineWidth',3,'Color','red');



% figure; implot(RGB, HSV_S, DLD, DLD_improved, Marking, Marking2, RGB);
hold on;

% 复制自上文绘图
hold on;
plot(vanishPoint(1), vanishPoint(2), 'ro');
% 水平线horison  把消失点所在的水平位置设为地平线
plotline([1, vanishPoint(2)], [size(Tree, 2), vanishPoint(2)], 'LineWidth',3,'Color','blue');
endPoint1 = linemeetpoint( BoudaryLine_left.point1, BoudaryLine_left.point2, [1, size(Tree, 1)], [4, size(Tree, 1)]); % 注意坐标反的 试试plot(1, 5, 'b*');
endPoint2 = linemeetpoint( BoudaryLine_right.point1, BoudaryLine_right.point2, [1, size(Tree, 1)], [4, size(Tree, 1)]);
plot(endPoint1(1), endPoint1(2), 'r*');
plot(endPoint2(1), endPoint2(2), 'r*');

plotline(vanishPoint, endPoint1,'LineWidth',3,'Color','yellow');
plotline(vanishPoint, endPoint2,'LineWidth',3,'Color','yellow');


% 添加显示区域



% 固定宽度的DLD 采用模板也行吧
% - HSV_V 作为改进 颜色信息利用上了
% template_DLD = ones(1, 2*mw);
% template_DLD(1:ceil(mw/2)) = -1;
% template_DLD(ceil(mw*3/2):mw*2) = -1;

% DLD_V = imfilter(HSV_V(horison:end,:), template_DLD, 'corr', 'replicate'); 
% DLD_S = imfilter(HSV_S(horison:end,:), -template_DLD, 'corr', 'replicate'); 

%figure;imshow(DLD);
% Markingness = HSV_V .* (1 - HSV_S) ;
% Marking = Markingness > 0.8;
% (HSV_H + 0.5 < HSV_V) & (HSV_S + 0.5 < HSV_V);

function DLD = filterDLD(GRAY)
% 类似元胞自动机的更新思想
[h, w] = size(GRAY);
DLD = zeros(h, w);
for r = 1 : h % size(Tree, 1) : -1 : (horison-1)
	mw = ceil(5 * r / h);% marking width
	% int16( 10 * (r - horison) / (height - horison) );
	for c = (mw+1) : w - mw 
	% 直接采用该公式的效果不好，改成添加饱和度 可以过滤掉阴影
	% DLD_improved = 
		DLD(r, c) = 2* GRAY(r, c) - (GRAY(r , c - mw)+GRAY(r , c + mw)) - abs(GRAY(r , c - mw) - GRAY(r , c + mw));
	end
end 

return;

% vanishPoint

% 车道标记检测的新方法
% DLD方法

% 三角形区域
% 车道标记？ 对HSV_V 进行histeq
% HSV_V = histeq(HSV_V);
% 亮度足够大 HSV_S 足够小
% HSV_S = 0 尽量不要和V有关，否则受光照影响大
% 亮度相对高，饱和度相对低，融合DLD
% 亮度减去左侧亮度 
% 消失点的高度

Filtered = medfilt2(Saturate2);
% Filtered = filter2(fspecial('average',5), Filtered);
Tree =  im2bw(Filtered, 0.3);
Tree = imfill(Tree, 'holes'); 
Tree = bwareaopen(Tree, 100);

% Saturate_adjust = Saturate - Shadowness*0.7;



implot(RGB, Shadowness, Saturate, Tree1, Treeness);
return;

% 也可以简单地取近似 Saturate = double(RGB_MAX - RGB_MIN) ./ double(RGB_MAX + 1) ;
% saturate 的问题在于 阴影的饱和度很大，会干扰
RG_MAX = max(RGB_R, RGB_G);
RG_MIN = min(RGB_R, RGB_B);

Saturate3 = double(RG_MAX - RG_MIN) ./ double(RG_MAX + 1) ;
% 研究要有方法，不能瞎猜，最好是分析数据，发现规律，做了图像标记后，观察数据！以后的工作就是这个！ 
% 阴影的B分量明显偏大
%RG_MAX比RGB_G更显著 double(RGB_G - RGB_B) ./ double(RGB_G + 1) ;
%分子再次加强
Saturate2 = double(RG_MAX - RGB_B) ./ double(RG_MAX + 1) ;
%Saturate3 = 2*Saturate2 + Saturate ;

% 一半的马路存在阴影的情形下 或者是墙壁，没有绿色
% 在大面积阴影内部找边缘修补 对边缘图进行修复
% 注意不能用最大类间方差graythresh(Saturate2)取最优阈值 而是均衡化后固定阈值 也不建议均衡化
% 根据最大值调整阈值max(Saturate2(:)) 基本都是0.99**
% 去掉孤立的噪点 直接先进行中值滤波就没有噪点了

% 二值图像去噪bwareaopen 去除小面积的 稍微膨胀下（但引入噪声）
% f=bwareaopen(h,50);
% figure,imshow(f)
% g=imdilate(f,strel('disk',2));figure,imshow(g)
% 

% Shadow = RGB_MAX < 80; 效果不好
% Shadow = Saturate - Saturate2;
% Shadow =  im2bw(Shadow, 0.6);
% Shadow = bwareaopen(Shadow, 100);
% Shadow =  double(RGB_B - RG_MAX) ./ double(RGB_B + 1);

% bw1 = imfill(bw, 'holes'); 填充二值图中的洞
% 注意图片是非负的类型 取-则为取反运算

% Edge = edge(Shadow, 'sobel'); % 创新点，将阴影区域和非阴影区域独立找特征点，之后结合
% Edge = Edge & Shadow;

% 提取特征点 

figure; % HSV_V,Saturate3,
implot(RGB, HSV_H, Saturate, Saturate2,  Tree, Saturate3);
return;

Filtered_Median = medfilt2(HSV_V);
TREENESS = abs(HSV_V - Filtered_Median);
TREENESS = histeq(TREENESS);

TREE = im2bw(TREENESS) & (HSV_S > 0.7);
% MARKING = (HSV_V - HSV_S) ./ (double(RGB_MAX - RGB_MIN  + 1)/255.0);
% MARKING = mat2gray(MARKING);
% MARKING = histeq(MARKING);

figure;
implot(RGB, HSV_H, HSV_S, HSV_V, TREENESS, TREE);
% implot(RGB, HSV_H, HSV_S, HSV_V, abs(HSV_H - HSV_S) .* HSV_S);
% 去除饱和度大于树木的即可！
return;
% + T 添加阈值

% HSV_MIN = min(min(HSV_H, HSV_S) , HSV_V);
% HSV_MAX = max(max(HSV_H, HSV_S) , HSV_V);
% 尝试了将HSV分量线性运算的结果，效果不好，消除阴影的同时路面也不突出了

%ROAD = (HSV_V - HSV_S > 0.5);
% ROAD = histeq(HSV_MEAN);

% implot(RGB, HSV_H, HSV_S, HSV_V, RGB_R, RGB_G, RGB_B);
% 
implot(RGB, HSV_H, HSV_S, HSV_V, (RGB_MAX<30), (RGB_MAX<60), (RGB_MAX<90));
% (RGB_MAX<60) 比较合适
% SHADOW = 

return;


GREENNESS = (255 + max(double(RGB_G), double(RGB_R)) - double(RGB_B))/2;
% 偏绿偏黄
TREENESS = (RGB_R + RGB_G - RGB_B);
% TREENESS = 255 * double(TREENESS + 255)/ double( 510 + 255);

TREE = GREENNESS > 125; % HSV_S/ > 0.5; % 非常饱和 且明显偏绿

% 找到非阴影的彩色点，即饱和度足够大，但亮度不是黑色的
% ROAD = HSV_V > 0.3;
SHADOW = (HSV_H > HSV_V) & (HSV_S > HSV_V) & (RGB_MAX < 30);


BLUENESS =  (255 + double(RGB_B) - max(double(RGB_R), double(RGB_G)))/2 ; % RGB:0-255 HSV:0-1

BLUE = BLUENESS > 125; % 固定阈值
SKYNESS = (HSV_V + 255 - HSV_S)/2;
SKY = (HSV_V > HSV_H + 0.2) & (HSV_H > HSV_S + 0.2) & (HSV_V - HSV_S > 0.6); % & BLUE 天不一定蓝，阴天
SATURATELESS = (HSV_H > HSV_S) & (HSV_V > HSV_S);

MARKING = (HSV_H + 0.5 < HSV_V) & (HSV_S + 0.5 < HSV_V);
% ROAD = (SATURATELESS | SHADOW > SKY); 


% 局部阈值

%implot(RGB, TEST);return;
% 作为因子比较好，正比反比
% imshow(RGB);
implot(RGB, BLUENESS, SKYNESS, SKY, SATURATELESS, SHADOW, MARKING,ROAD);



