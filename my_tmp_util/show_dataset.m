

%% Temp usage
% JPG(1024x1280x3) --> PNG
% not support yet.TODO foreach_file_do('%datasets\roma\*\groundtruth\*.jpg', jpg2png);

% jpg2png = @(x)imwrite(im2bw(imread(x),0.5),[vvFile.pn(x),'.png']);
% % foreach_file_do('%datasets\roma\BDXD54\groundtruth\IMG00002.jpg', jpg2png);
% foreach_file_do('%datasets\roma\BDXD54\groundtruth\*.jpg', jpg2png);
% foreach_file_do('%datasets\roma\BDXN01\groundtruth\*.jpg', jpg2png);
% foreach_file_do('%datasets\roma\IRC04510\groundtruth\*.jpg', jpg2png);
% foreach_file_do('%datasets\roma\IRC041500\groundtruth\*.jpg', jpg2png);
% foreach_file_do('%datasets\roma\LRAlargeur13032003\groundtruth\*.jpg', jpg2png);
% foreach_file_do('%datasets\roma\LRAlargeur14062002\groundtruth\*.jpg', jpg2png);
% foreach_file_do('%datasets\roma\LRAlargeur26032003\groundtruth\*.jpg', jpg2png);
% foreach_file_do('%datasets\roma\RD116\groundtruth\*.jpg', jpg2png);
% foreach_file_do('%datasets\roma\RouenN8IRC051900\groundtruth\*.jpg', jpg2png);
% foreach_file_do('%datasets\roma\RouenN8IRC052310\groundtruth\*.jpg', jpg2png);

%% NICTA
% nicta.afterRain

nicta.afterRain.path = '%datasets\nicta-RoadImageDatabase\After-Rain';
nicta.afterRain.imgname = '*.tif';
nicta.afterRain.rimgname = '*.png';

%% KITTI ROAD
% kitti.data_road.training

% um 95 000000-um_000094
% umm 96 000000-umm_000095
% uu 98 000000-uu_000097
% 289 in total

% gt: 384 road 289 + lane (95 um) 
kitti.data_road.training.path = '%datasets\KITTI\data_road\training';
kitti.data_road.training.imgname = 'image_2\*.png';
kitti.data_road.training.rimgname = 'gt_image_2\*road*.png';


%% ROMA ROAD
roma.BDXD54.path = '%datasets\roma\BDXD54';
roma.BDXD54.imgname = '*.jpg';
roma.BDXD54.rimgname = '*.png';

dataset = roma.BDXD54; % kitti.data_road.training;
d = vvDataset(dataset.path);

%files = AfterRain.filenames('*.tif');
%montage(files(1:8:end));

%AfterRain.select('*.tif');
%implay(AfterRain); % montage(AfterRain);

RawImgs = d.imgsarray(dataset.imgname);
GtImgs = d.imgsarray(dataset.rimgname);

if 1 == size(GtImgs, 3) % gray image
    GtImgs = repmat(uint8(GtImgs.*255), [1, 1, 3]);% binary to rgb
end 
% OverlayImgs = cell2mat(arrayfun(@(x,y)imoverlay(x{:},y{:}), ...
% num2cell(RawImgs,1:3),num2cell(GtImgs,1:3),...
% 'UniformOutput', false));
% 
imdrawmask = @(x,y)(x + imoverlay(x,y,[255 0 0]));
% MaskedImgs = cell2mat(arrayfun(@(x,y)imdrawmask(x{:},y{:}), ...
% num2cell(RawImgs,1:3),num2cell(GtImgs,1:3),...
% 'UniformOutput', false));
    
%drawmask boundary
imdrawmask2 = @(x,y)(x + imoverlay(x,y,[255 0 0]) + imoverlay(x,bwperim(y),[0 255 0]));
immean = @(x,y)(x/2+y/2);
disp_method = immean;% imdrawmask imdrawmask2  @mean

MaskedImgs = cell2mat(arrayfun(@(x,y)disp_method(x{:},y{:}), ...
num2cell(RawImgs,1:3),num2cell(GtImgs,1:3),...
'UniformOutput', false));

% PaintImgs
% implay([GtImgs;MaskedImgs]);
implay(MaskedImgs);
% implay([RawImgs;MaskedImgs]);
%implay([RawImgs RgbGtImgs;...
%MaskedImgs OverlayImgs]);