function RoadRegion = vvGetRoadFace(image)
% 返回近视野路面的鸟瞰灰度图（颜色信息用不上）
% 降低分辨率便于处理，提高处理效果。检测精度问题？
% 用低分辨率处理，
% 得到路面区域再回到高分辨率 注意图像回到高分辨率会出现锯齿，但参数不会，所以在低分辨率提取参数是可行的
% 或者变化分辨率
% 大量阴影 
% dataset\roma\BDXD54\IMG00071.jpg
% dataset\roma\BDXD54\IMG00030.jpg
% foreach_file_do('dataset\roma\BDXD54\*.jpg',@vvGetRoadFace)

% 先对图像做倒转，不然坐标变换太麻烦

if isstr(image)
	disp(['start processing image:', image]);
	image = imread(image);
end 

isresize = false;
% 改为处理边界时用resize的图，resize放到边界处理内部，得出参数后进行投射变换
if isresize == true
	numRow = 150;
	numColumn = 200;
	image = imresize(image, [numRow, numColumn]);
else
	[numRow, numColumn, nchannel] = size(image);
end 

if nchannel ~= 3
	error('input must be a colour image.');
end

[horizon, PointO, PointL, PointR] = detectRoadBoundary(image);
image = rgb2gray(image);
RoadRegion = perspectiveTrans(image, horizon, PointO, PointL, PointR);
imdump(RoadRegion);

%-------------------------------------------------------------------%
% ISM2015 中为提取左右边界，这里只提取三个特殊点，从而进行投影变换
% 其他参数可以通过这三个点求得
function [horizon, PointO, PointL, PointR] = detectRoadBoundary(original) 

[height, width, nchannel] = size(original);

numRow = 150; %min(height, 150);
numColumn = 200; %min(width, 200);

image = imresize(original, [numRow, numColumn]);

horizon =  ceil(numRow /3); % numRow/2;
left = zeros(horizon);
right = numColumn * ones(horizon);
theta = [-89:89];

%% image preprocessing
% 很有可能下半部分全是阴影，使得检测无法进行
ROI = image( horizon:end,:,:);
% ROI = RGB;

[RGB_R, RGB_G, RGB_B] = getChannel(ROI);
RGB_min = min(min(RGB_R, RGB_G) , RGB_B);
RGB_max = max(max(RGB_R, RGB_G) , RGB_B);
S_modified = double(RGB_max - RGB_B) ./ double(RGB_max + 1);

% road boundary detection
% 阈值要足够高 0.3
% 改进：左侧，右侧独立进行阈值化，防止单边的影响！确保两侧都有！可以处理图像左右光照不对称的情形
% S_bw = S_modified > 0.5*max(S_modified(:));
% S_bw = imclose(S_bw, strel('square',3)); %imdilate imclose imopen
% S_bw = bwareaopen(S_bw, 500);

S_L = S_modified(:,1:floor(numColumn/2));
S_R = S_modified(:,floor(numColumn/2)+1:end); % 注意不能写ceil ceil可能等于floor

S_bw_L = S_L > 0.45*max(S_L(:)); %  0.3 0.2 % 用histeq和graythresh效果不好
S_bw_L_imclose = imclose(S_bw_L, strel('square',3)); %imdilate imclose imopen
S_bw_L_areaopen = bwareaopen(S_bw_L_imclose, 200); % 去除车道线

S_bw_R = S_R > 0.45*max(S_R(:));
S_bw_R_imclose = imclose(S_bw_R, strel('square',3));
S_bw_R_areaopen = bwareaopen(S_bw_R_imclose, 200);

S_bw = [S_bw_L_areaopen, S_bw_R_areaopen];

imdump(S_modified, S_bw,...
	S_bw_L, S_bw_L_imclose, S_bw_L_areaopen,...
	S_bw_R, S_bw_R_imclose, S_bw_R_areaopen);


[BoundaryL, BoundaryR] = bwExtractBoundaryPoints(S_bw);
RemovedRegion = zeros(horizon-1, numColumn); % 为了正确显示直线，补上去掉的区域
lineL = bwFitLine([RemovedRegion; BoundaryL], [0:89]);
lineR = bwFitLine([RemovedRegion; BoundaryR], [-89:0]);

% lineL = bwFitLine(BoundaryL);
% lineR = bwFitLine(BoundaryR);

try
	thetaL = lineL.theta;
	thetaR = lineR.theta;
	theta = [ceil(min(thetaL, thetaR)):floor(max(thetaL, thetaR))];
catch ME
% 直线没有找到的情形
    % debug
	lineL
	lineR
	% close all;
	figure;
	implot(RGB, S_modified, S_bw, BoundaryL, BoundaryR);
	error(['Sorry, no boundary is found!']);
	return;
end
	
PointO = linemeetpoint( lineL.point1, lineL.point2, lineR.point1, lineR.point2 ); 
PointL = linemeetpoint( lineL.point1, lineL.point2, [1, numRow], [2, numRow]); 
PointR = linemeetpoint( lineR.point1, lineR.point2, [1, numRow], [2, numRow]);

% 绘图 先划线
h = implot(original, image);
title('detected');
% left and right boundary line
plotline(PointO, PointL,'LineWidth',3,'Color','yellow');
plotline(PointO, PointR,'LineWidth',3,'Color','green');
% horizon line
plotline([1, PointO(2)], [numColumn, PointO(2)], 'LineWidth',3,'Color','blue');
% vanishing point
plot(PointO(1), PointO(2), 'ro', 'markersize', 10);
% 水平线horizon  把消失点所在的水平位置设为地平线
plot(PointL(1), PointL(2), 'r*');
plot(PointR(1), PointR(2), 'r*');
% feature points
for r = horizon : numRow % 1 : (numRow/2) 
	for c = 1 : numColumn
		if 1 == BoundaryL(r - horizon + 1, c)
			plot(c, r, 'y+');
		end
		if 1 == BoundaryR(r - horizon + 1, c)
			plot(c, r, 'g+');
		end
	end
end 
imdump(h);

% 等前面 horizon 用完
horizon = floor(PointO(2)); % Notice: 特殊图片: horizon为负数 消失点在图像外

% 左右边界用不上了
% h = numRow - horizon + 1; % horizon : numRow
% for r = 1 : numRow
% 	left(r) = ceil( PointO(1) - (PointO(1) - PointL(1))* r / h);
% 	right(r) = ceil( PointO(1) + (PointR(1) - PointO(1))* r / h);
% end

% 还原resize带来的影响
horizon = ceil(horizon*height/numRow);

PointO(1) = PointO(1)*width/numColumn;
PointO(2) = PointO(2)*height/numRow;
PointL(1) = PointL(1)*width/numColumn;
PointL(2) = PointL(2)*height/numRow;
PointR(1) = PointR(1)*width/numColumn;
PointR(2) = PointR(2)*height/numRow;

function Transformed = perspectiveTrans(image, horizon, PointO, PointL, PointR)
% RoadFace为水平线以下的区域
% 三个特征点还原到大图的水平线以下

ischop = false; % 裁剪得越多，可用的数据越少? true; %

if ischop
	% 裁剪掉水平线以上部分
	% horizon = 300;
	I = image(horizon:end,:,:);
	% 点的坐标调整
	PointO(2) = PointO(2) - horizon;
	PointL(2) = PointL(2) - horizon;
	PointR(2) = PointR(2) - horizon;
	% 裁剪后的坐标调整结束
else
	I = image;
end

[numRow, numColumn, nchannel] = size(I);

% 透视变换
PointLU = PointO/2 + PointL/2;
PointRU = PointO/2 + PointR/2;

% 显示特征点
% figure;subplot(1,2,1);imshow(I);hold on;
% plot(PointLU(1), PointLU(2), 'yo', 'markersize', 10);
% plot(PointRU(1), PointRU(2), 'bo', 'markersize', 10);
% plot(PointL(1), PointL(2), 'y*', 'markersize', 10);
% plot(PointR(1), PointR(2), 'b*', 'markersize', 10);

% % 求变换矩阵：
% TForm = cp2tform(B,A,'projective');
% round(tformfwd(TForm,[400 240]));% 每个点对应到新的位置

B = [PointLU;PointRU; PointL;PointR];% 源图像中的点的坐标矩阵为： 点在图像外
% 透视结果仅仅是拉伸
% 还原成大小 50*100 150*200
% outCols = 100; outRows = 50;
outCols = 80; outRows = 60; % 三个像素宽度
% outCols = 40; outRows = 30; % 一个像素宽度

% TODO：改为仅对所选区域变换
A = [1, 1;outCols,1;1,outRows;outCols, outRows];
% 太大了，造成响应慢 生成更大的空间 7988*6241 A = [1, 1;numColumn,1;1,numRow;numColumn, numRow];% 目标图像中对应的顶点坐标为：

tform = fitgeotrans(B, A, 'projective');
% tform = cp2tform(B,A,'projective');
Transformed = imwarp(I,tform, 'OutputView', imref2d([outRows, outCols]));

%-------------------------------------------------------------------%
function line = bwFitLine(BW, Theta)
%Hough Transform
if nargin < 2
	[H,theta,rho] = hough(BW);
else 
	[H,theta,rho] = hough(BW, 'Theta', Theta);
end

% Finding the Hough peaks
P = houghpeaks(H, 1);
x = theta(P(:,2));
y = rho(P(:,1));

%Fill the gaps of Edges and set the Minimum length of a line
lines = houghlines(BW,theta,rho,P, 'MinLength',10, 'FillGap',570);
line = lines(1);

% figure;
% imshow(H,[],'XData',theta,'YData',rho,'InitialMagnification','fit');
% xlabel('\theta'), ylabel('\rho');
% axis on, axis normal, hold on;
% plot(theta(P(:,2)),rho(P(:,1)),'s','color','white');
% figure;

%-------------------------------------------------------------------%
function [BoundaryL, BoundaryR] = bwExtractBoundaryPoints(BW)
[numRow, numColumn] = size(BW);

Boundary_candidate = zeros(numRow, numColumn);
BoundaryL = zeros(numRow, numColumn);
BoundaryR = zeros(numRow, numColumn);
ScanB = zeros(numRow, numColumn);
ScanL = zeros(numRow, numColumn);
ScanR = zeros(numRow, numColumn);

for c = 1 : numColumn
	for r = numRow : -1 : 1
		if 1 == BW(r, c)
			Boundary_candidate(r, c) = 1;
			break;
		end
		ScanB(r, c) = 1;
	end
end 
for r = numRow : -1 : 1
	for c = ceil(numColumn/2) : -1 : 1
		if 1 == Boundary_candidate(r, c)
			BoundaryL(r, c) = 1;
			break;
		end
		ScanL(r, c) = 1;
	end
	for c = floor(numColumn/2) : numColumn
		if 1 == Boundary_candidate(r, c)
			BoundaryR(r, c) = 1;
			break;
		end
		ScanR(r, c) = 1;
	end
end

imdump(Boundary_candidate, BoundaryL, BoundaryR);