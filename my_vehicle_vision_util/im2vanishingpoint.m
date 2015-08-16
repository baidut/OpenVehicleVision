function pointVP = im2vanishingpoint(ori1, ori2)
% im2vanishingpoint(imread('dataset\dataset4\sequence\04562.jpg'),imread('dataset\dataset4\sequence\04563.jpg'));
% im2vanishingpoint(imread('dataset\dataset4\sequence\04564.jpg'),imread('dataset\dataset4\sequence\04565.jpg'));

% folder = 'D:\Users\zqying\Documents\Github\OpenVehicleVision\dataset\dataset4\sequence\';
% % load the two frames
% ori1 = imread([folder '04562.jpg']);
% ori2 = imread([folder '04563.jpg']);

% =============================================== %

nCols = 200;
nRows = 100;

im1 = im2double(imresize(ori1, [nRows, nCols]));
im2 = im2double(imresize(ori2, [nRows, nCols]));

% set optical flow parameters (see Coarse2FineTwoFrames.m for the definition of the parameters)
alpha = 0.012;
ratio = 0.75;
minWidth = 20;
nOuterFPIterations = 7;
nInnerFPIterations = 1;
nSORIterations = 30;

para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];

% this is the core part of calling the mexed dll file for computing optical flow
% it also returns the time that is needed for two-frame estimation
tic;
[vx,vy,warpI2] = Coarse2FineTwoFrames(im1,im2,para);
toc

% figure, implot(im1, im2, warpI2), maxfig;

% plotFlow(vx, vy, im1, 10);
% maxfig;

implot(vx, vy); 
pointVP = getVP(vx, vy);

if showVP
	figure;imshow(im1,[0 255]); hold on;
	plot(pointVP(1), pointVP(2), 'yo', 'markersize', 10);
	text(pointVP(1), pointVP(2)+2, ['\color{yellow}', sprintf('%.2f, %.2f',pointVP(1), pointVP(2))]);
	maxfig;
end

% 先按照0做阈值分割
function pointVP = getVP(vx, vy)

BW_vx = vx > 0;
BW_vy = vy > 0;

% figure; implot(BW_vx, BW_vy);

% 初始VP为图像中心
VPx = size(vx,2)/2.0;
VPy = size(vx,1)/2.0;

% 只考虑了图像中心区域
for r = ceil(size(vx,1)/4) : ceil(size(vx,1)*3/4) 
	for c = ceil(size(vx,2)/4) : ceil(size(vx,2)*3/4)
		if BW_vx(r,c-1) == 0 && BW_vx(r,c) == 1
			VPx = double(VPx + c)/2;
			break;
		end
	end
end 
for r = ceil(size(vx,1)/4) : ceil(size(vx,1)*3/4) 
	for c = ceil(size(vx,2)/4) : ceil(size(vx,2)*3/4)
		if BW_vy(r-1,c) == 0 && BW_vy(r,c) == 1
			VPy = double(VPy + r)/2;
			break;
		end
	end
end 

pointVP = [VPx, VPy];

% 注意vx为浮点数
% 每行的绝对值最小值点做平均
% 正负中间 左侧大于0，右侧小于0

% 由于是渐变的，可以改成启发式地找中间值，二分法
% 下一行从上一行附近找值

% VPx = floor(VPx);
% VPy = floor(VPy);

% 1. set(gca,'YDir','reverse');作用何在?
% 2. 消失点是图像中心- 画出中心点看有无变化
% 3. x显示的图中横纵轴合成不正确