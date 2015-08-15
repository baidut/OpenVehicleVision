function im2vanishingpoint(ori1, ori2)

% folder = 'D:\Users\zqying\Documents\Github\OpenVehicleVision\dataset\dataset4\sequence\';
% example = 'roadscene';

% % load the two frames
% ori1 = imread([folder '04562.jpg']);
% ori2 = imread([folder '04563.jpg']);

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
rSize=10;%5;
scale=3;
u = vx;
v = vy;

% Enhance the quiver plot visually by showing one vector per region
figure; imshow(im1,[0 255]); hold on;
for i=1:size(u,1) %u的行数 u v 一样大小
    for j=1:size(u,2) %u的列数
        if floor(i/rSize)~=i/rSize || floor(j/rSize)~=j/rSize %判断不等 5的倍数出有点
            u(i,j)=0;
            v(i,j)=0;
        end
    end
end
quiver(u, v, scale, 'color', 'r', 'linewidth', 2);%线宽是2，颜色是b，即蓝色，r是红色
% set(gca,'YDir','reverse');%gca当前轴处理 
quiver(u, zeros(size(v)), scale, 'color', 'g', 'linewidth', 2);%线宽是2，颜色是b，即蓝色，r是红色
% set(gca,'YDir','reverse');%gca当前轴处理 
quiver(zeros(size(u)), v, scale, 'color', 'b', 'linewidth', 2);%线宽是2，颜色是b，即蓝色，r是红色


% 作用何在