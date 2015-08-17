function [lineL, lineR] = im2boundaryline(I) 
% 不推荐使用该函数，已不再维护，建议使用BoundDetector
% call bw2boundaries,bw2line

[height, width, nchannel] = size(I);

if nchannel ~= 3
	error('Color image is needed.');
end

numRow = 150; %min(height, 150);
numColumn = 200; %min(width, 200);

image = imresize(I, [numRow, numColumn]);

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
imwrite(S_modified, 'results/vvGetRoadFace/S_modified.jpg');

% road boundary detection
% 阈值要足够高 0.3
% 改进：左侧，右侧独立进行阈值化，防止单边的影响！确保两侧都有！可以处理图像左右光照不对称的情形

S_L = S_modified(:,1:floor(numColumn/2));
S_R = S_modified(:,floor(numColumn/2)+1:end); % 注意不能写ceil ceil可能等于floor

% function BW = extractBoundaries(Gray)

S_bw_L = S_L > 0.45*max(S_L(:)); %  0.3 0.2 % 用histeq和graythresh效果不好
imwrite(S_bw_L, 'results/vvGetRoadFace/S_bw_L.jpg');
S_bw_L = imclose(S_bw_L, strel('square',3)); %imdilate imclose imopen
imwrite(S_bw_L, 'results/vvGetRoadFace/S_bw_L_imclose.jpg');
S_bw_L = bwareaopen(S_bw_L, 200); % 车道线可能成为干扰
imwrite(S_bw_L, 'results/vvGetRoadFace/S_bw_L_areaopen.jpg');

S_bw_R = S_R > 0.45*max(S_R(:));
imwrite(S_bw_R, 'results/vvGetRoadFace/S_bw_R.jpg');
S_bw_R = imclose(S_bw_R, strel('square',3));
imwrite(S_bw_R, 'results/vvGetRoadFace/S_bw_R_imclose.jpg');
S_bw_R = bwareaopen(S_bw_R, 200);
imwrite(S_bw_R, 'results/vvGetRoadFace/S_bw_R_areaopen.jpg');

S_bw = [S_bw_L, S_bw_R];
imwrite(S_bw, 'results/vvGetRoadFace/S_bw.jpg');

% S_bw = S_modified > 0.5*max(S_modified(:)); %  0.3 0.2 % 用histeq和graythresh效果不好
% imwrite(S_bw, 'results/vvGetRoadFace/S_bw.jpg');
% S_bw = imclose(S_bw, strel('square',3)); %imdilate imclose imopen
% imwrite(S_bw, 'results/vvGetRoadFace/S_bw_imclose.jpg');
% S_bw = bwareaopen(S_bw, 500); % 车道线可能成为干扰
% imwrite(S_bw, 'results/vvGetRoadFace/S_bw_areaopen.jpg');

[BoundaryL, BoundaryR] = bw2boundaries(S_bw);
RemovedRegion = zeros(horizon-1, numColumn); % 为了正确显示直线，补上去掉的区域
lineL = bw2line([RemovedRegion; BoundaryL], [0:89]);
lineR = bw2line([RemovedRegion; BoundaryR], [-89:0]);

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
figure;
imshow(image);title('Road face detection');
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

lineL.point1 = PointO;
lineL.point2 = PointL;
lineR.point1 = PointO;
lineR.point2 = PointR;

% figure;
% imshow(I);
% hold on;
% plot(PointO(1), PointO(2), 'ro', 'markersize', 10);
% % 水平线horizon  把消失点所在的水平位置设为地平线
% plot(PointL(1), PointL(2), 'r*');
% plot(PointR(1), PointR(2), 'r*');