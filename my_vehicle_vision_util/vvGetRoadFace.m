function RoadRegion = vvGetRoadFace(image)
% 降低分辨率便于处理，提高处理效果。检测精度问题？
% 用低分辨率处理，
% 得到路面区域再回到高分辨率 注意图像回到高分辨率会出现锯齿，但参数不会，所以在低分辨率提取参数是可行的
% 或者变化分辨率

if isstr(image)
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

figure;
imshow(image); 
hold on;% 供描点划线，中间结果写入文件

[horizon, left, right, theta] = detectRoadBoundary(image);

%-------------------------------------------------------------------%
function [horizon, left, right, theta] = detectRoadBoundary(RGB) 
numRow = size(RGB, 1);
numColumn = size(RGB, 2);
horizon =  ceil(numRow /3); % numRow/2;
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
S_bw = S_modified > 0.3; %  0.3 0.2 % 用histeq和graythresh效果不好
S_bw = imclose(S_bw, strel('square',3)); %imdilate imclose imopen
S_bw = bwareaopen(S_bw, 50); % 车道线可能成为干扰

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
	
PointO = linemeetpoint( lineL.point1, lineL.point2, lineR(1).point1, lineR.point2 ); 
PointL = linemeetpoint( lineL.point1, lineL.point2, [1, numRow], [2, numRow]); 
PointR = linemeetpoint( lineR.point1, lineR.point2, [1, numRow], [2, numRow]);

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

% return;

% 透视变换
PointLU = PointO/2 + PointL/2;
PointRU = PointO/2 + PointR/2;
plot(PointLU(1), PointLU(2), 'yo', 'markersize', 10);
plot(PointRU(1), PointRU(2), 'bo', 'markersize', 10);

B = [PointLU;PointRU; PointL;PointR];% 源图像中的点的坐标矩阵为： 点在图像外
% 透视结果仅仅是拉伸
A = [1, 1;numColumn,1;1,numRow;numColumn, numRow];% 目标图像中对应的顶点坐标为：
% % 求变换矩阵：
% TForm = cp2tform(B,A,'projective');
% round(tformfwd(TForm,[400 240]));% 每个点对应到新的位置
A
B
I = RGB;

udata = [0 numColumn];  vdata = [0 numRow];  % input coordinate system
tform = maketform('projective',B,A);
[B,xdata,ydata] = imtransform(I,tform,'bicubic','udata',udata,...
                                                'vdata',vdata,...
                                                'size',size(I),...
                                                'fill',128);
imshow(I,'XData',udata,'YData',vdata), axis on
figure, imshow(B,'XData',xdata,'YData',ydata), axis on

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
	for c = (numColumn/2) : -1 : 1
		if 1 == Boundary_candidate(r, c)
			BoundaryL(r, c) = 1;
			break;
		end
		ScanL(r, c) = 1;
	end
	for c = (numColumn/2) : numColumn
		if 1 == Boundary_candidate(r, c)
			BoundaryR(r, c) = 1;
			break;
		end
		ScanR(r, c) = 1;
	end
end
