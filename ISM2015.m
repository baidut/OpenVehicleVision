function ISM2015(FILENAME)
%ISM2015 demonstrate the algorithm proposed in following paper: 
% An Illumination-Robust Approach for  Feature-Based Road Detection
%
% ISM2015(FILENAME) display road detection result of the image file
% specified by the string FILENAME. 
%
% Example:
%   foreach_file_do('dataset\*ISM2015*.jpg', @ISM2015);
%
% NOTE: 
%
% Email: yinzhenqiang # gmail.com
% Website: http://baidut.github.io/
% Github: https://github.com/baidut
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% log:
% 2015-07-14: Complete
% to-do:
% * extract edge of lane-marking feature image
% + adaptive threshold
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RGB = imread(FILENAME);

numRow = 150;
numColumn = 200;
RGB = imresize(RGB, [numRow, numColumn]);

figure;
imshow(RGB); 
hold on;% 供描点划线，中间结果写入文件

[horizon, left, right, theta] = detectRoadBoundary(RGB);
detectLaneMarking(RGB, horizon, left, right, theta);

%-------------------------------------------------------------------%
function detectLaneMarking(RGB, horizon, left, right, theta);
numRow = size(RGB, 1);
ROI = RGB(horizon:end,:,:);
[RGB_R, RGB_G, RGB_B] = getChannel(ROI);
V_ROI = double(max(RGB_R, max(RGB_G, RGB_B)))/255; % 虽然范围不同(ROI调整)，但仍是重复的计算

[h, w] = size(V_ROI);

DldFeature = zeros(h, w);
for r = 1 : h
	mw = ceil(5 * r / h); % marking width
	for c = (mw + max(1, left(r))) : (min(right(r), w) - mw )
		DldFeature(r, c) = V_ROI(r, c) ./ (V_ROI(r , c - mw)+V_ROI(r , c + mw));
	end
end 

DldFeature = mat2gray(DldFeature); % 归一化
Marking = (DldFeature > 0.6); % 0.7 DLD方法有缺陷 以后再说
% Marking = im2bw(DldFeature, graythresh(DldFeature));
Marking = imclose(Marking, strel('square',3)); % imopen
Marking = bwareaopen(Marking, 15);
RemovedRegion = zeros(horizon-1, w);
line = bwFitLine([RemovedRegion; Marking], theta);

% implot(RGB, DldFeature, Marking);

try
% 与horizon交点
PointS = linemeetpoint( line.point1, line.point2, [1, horizon], [2, horizon]);
% 与底边交点
PointE = linemeetpoint( line.point1, line.point2, [1, numRow], [2, numRow]);
plotline(PointS, PointE,'LineWidth',3,'Color','red');
catch ME
	% close all;
	implot(RGB, DldFeature, Marking);
end 

%-------------------------------------------------------------------%
function [horizon, left, right, theta] = detectRoadBoundary(RGB) 
numRow = size(RGB, 1);
numColumn = size(RGB, 2);
horizon =  numRow /3; % numRow/2;
left = zeros(horizon);
right = numColumn * ones(horizon);
theta = [-89:89];

%% image preprocessing
% 很有可能下半部分全是阴影，使得检测无法进行
ROI = RGB( horizon:end,:,:);
% ROI = RGB;

[RGB_R, RGB_G, RGB_B] = getChannel(ROI);
RGB_min = min(min(RGB_R, RGB_G) , RGB_B);
RGB_max = max(max(RGB_R, RGB_G) , RGB_B);
S_modified = double(RGB_max - RGB_B) ./ double(RGB_max + 1);

% road boundary detection
S_bw = S_modified > 0.4; %  0.3 0.2 % 用histeq和graythresh效果不好
S_bw = imclose(S_bw, strel('square',3)); %imdilate imclose imopen
S_bw = bwareaopen(S_bw, 50); % 车道线可能成为干扰

[BoundaryL, BoundaryR] = bwExtractBoundaryPoints(S_bw);
RemovedRegion = zeros(horizon-1, numColumn); % 为了正确显示直线，补上去掉的区域
lineL = bwFitLine([RemovedRegion; BoundaryL]);
lineR = bwFitLine([RemovedRegion; BoundaryR]);

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
	% error(['Sorry, no boundary is found!']);
	return;
end
	
PointO = linemeetpoint( lineL.point1, lineL.point2, lineR(1).point1, lineR.point2 ); 
PointL = linemeetpoint( lineL.point1, lineL.point2, [1, numColumn], [2, numColumn]); 
PointR = linemeetpoint( lineR.point1, lineR.point2, [1, numColumn], [2, numColumn]);

% 绘图 先划线
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
% 等前面 horizon 用完
horizon = floor(PointO(2)); % Notice: 特殊图片: horizon为负数 消失点在图像外
numRow = size(RGB, 1);
h = numRow - horizon + 1; % horizon : numRow
for r = 1 : numRow
	left(r) = ceil( PointO(1) - (PointO(1) - PointL(1))* r / h);
	right(r) = ceil( PointO(1) + (PointR(1) - PointO(1))* r / h);
end

%-------------------------------------------------------------------%
function line = bwFitLine(BW, Theta)
%Hough Transform
if nargin < 2
	[H,theta,rho] = hough(BW);
else 
	[H,theta,rho] = hough(BW, 'Theta', Theta);
end

% Finding the Hough peaks
P = houghpeaks(H, 2);
x = theta(P(:,2));
y = rho(P(:,1));

%Fill the gaps of Edges and set the Minimum length of a line
lines = houghlines(BW,theta,rho,P, 'MinLength',10, 'FillGap',570);
line = lines(1);

%-------------------------------------------------------------------%
function [BoundaryL, BoundaryR] = bwExtractBoundaryPoints(BW)
[numRow, numColumn] = size(BW);

Boundary_candidate = zeros(numRow, numColumn);
BoundaryL = Boundary_candidate;
BoundaryR = Boundary_candidate;

for c = 1 : numColumn
	for r = numRow : -1 : 1
		if 1 == BW(r, c)
			Boundary_candidate(r, c) = 1;
			break;
		end
	end
end 
for r = numRow : -1 : 1
	for c = (numColumn/2) : -1 : 1
		if 1 == BW(r, c)
			BoundaryL(r, c) = 1;
			break;
		end
	end
	for c = (numColumn/2) : numColumn
		if 1 == BW(r, c)
			BoundaryR(r, c) = 1;
			break;
		end
	end
end

BoundaryL = BoundaryL & Boundary_candidate;
BoundaryR = BoundaryR & Boundary_candidate;