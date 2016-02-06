function readRoad(str)
% RawVideo 1280:720 提取原始帧后进行预处理，预处理成640 480 截取的方式
% 直接resize 则长宽比变化

% 旋转图 1.直接转为鸟瞰图 2.截取ROI 再进行转换

% debarrel 似乎有点过分，需要综合考虑IPM
files = str2files(str);%* 0346 1201
for n = 1:numel(files)
    preprocess(files{n});
end

end

% 旋转会影响变换矩阵 失真不会影响 旋转后，调节即可

function preprocess(file)
[~,filename,~] = fileparts(file);
% figure;maxfig;
% set(gcf,'outerposition',get(0,'screensize'));
% foreach_file_do('%datasets\pku\1\*.jpg', @(f)readRoad(imread(f)));
%
%
% if nargin < 2
% 	info = [];
% end
%RawImg = imresize(RawImg,0.5);
RawImg = imread(file);
Debarrel = vvPreproc.debarrel(RawImg, -0.2, 'bordertype', 'fit');%-0.3); %-0.32 偏大
%imshow(Debarrel);

Derotate = vvPreproc.derotate(Debarrel, 2.5);
% implot(RawImg, Debarrel, Derotate);
% hold on;
%imshow(Derotate(end/5:end*4/5,end/5:end*4/5,:));
%imshow(Derotate(end/5:end*4/5,:,:));

%vvIPM.proj2topview(Derotate);

%% output 640x480 IPM image
load tform.mat
nRows = 160; nCols = 214;
I = vvIPM.proj2topview(Derotate, movingPoints,[nCols nRows], ...
    'OutputView', imref2d([3*nRows, 3*nCols],[-nCols 2*nCols], [-nRows, 2*nRows]));
imwrite(I(:,2:end-1,:), ['%datasets/pku/640x480IPM/', filename, '.jpg']);

%% ROI
%Roi = Derotate(149:628,337:976,:);
%imshow(Roi);

%% Save results.
% imwrite(Derotate,sprintf('%%datasets/pku/rotate/%s.jpg',filename));% IPM
% imwrite(Roi,sprintf('%%datasets/pku/640x480/%s.jpg',filename));

end