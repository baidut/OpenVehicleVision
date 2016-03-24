nicta.afterRain.path = '%datasets\nicta-RoadImageDatabase\After-Rain';
nicta.afterRain.imgname = '*.tif';
nicta.afterRain.rimgname = '*.png';

% um 95 000000-um_000094
% umm 96 000000-umm_000095
% uu 98 000000-uu_000097
% 289 in total

% gt: 384 road 289 + lane (95 um) 
kitti.data_road.training.path = '%datasets\KITTI\data_road\training';
kitti.data_road.training.imgname = 'image_2\*.png';
kitti.data_road.training.rimgname = 'gt_image_2\*road*.png';

dataset = kitti.data_road.training;
d = vvDataset(dataset.path);

%files = AfterRain.filenames('*.tif');
%montage(files(1:8:end));

%AfterRain.select('*.tif');
%implay(AfterRain); % montage(AfterRain);

RawImgs = d.imgsarray(dataset.imgname);
GtImgs = d.imgsarray(dataset.rimgname);
% RgbGtImgs = repmat(GtImgs.*255, [1, 1, 3]);% binary to rgb
    
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
implay([GtImgs;MaskedImgs]);
% implay([RawImgs;MaskedImgs]);
%implay([RawImgs RgbGtImgs;...
%MaskedImgs OverlayImgs]);