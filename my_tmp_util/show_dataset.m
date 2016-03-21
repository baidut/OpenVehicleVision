AfterRain = vvDataset('%datasets\nicta-RoadImageDatabase\After-Rain');

%files = AfterRain.filenames('*.tif');
%montage(files(1:8:end));

%AfterRain.select('*.tif');
%implay(AfterRain); % montage(AfterRain);

RawImgs = AfterRain.imgsarray('*.tif');
GtImgs = AfterRain.imgsarray('*.png');
RgbGtImgs = repmat(GtImgs.*255, [1, 1, 3]);% binary to rgb
    
% OverlayImgs = cell2mat(arrayfun(@(x,y)imoverlay(x{:},y{:}), ...
% num2cell(RawImgs,1:3),num2cell(GtImgs,1:3),...
% 'UniformOutput', false));
% 
% imdrawmask = @(x,y)(x + imoverlay(x,y,[255 0 0]));
% MaskedImgs = cell2mat(arrayfun(@(x,y)imdrawmask(x{:},y{:}), ...
% num2cell(RawImgs,1:3),num2cell(GtImgs,1:3),...
% 'UniformOutput', false));
    
%drawmask boundary
imdrawmask2 = @(x,y)(x + imoverlay(x,y,[255 0 0]) + imoverlay(x,bwperim(y),[0 255 0]));
MaskedImgs = cell2mat(arrayfun(@(x,y)imdrawmask(x{:},y{:}), ...
num2cell(RawImgs,1:3),num2cell(GtImgs,1:3),...
'UniformOutput', false));

% PaintImgs
implay([RawImgs MaskedImgs]);
%implay([RawImgs RgbGtImgs;...
%MaskedImgs OverlayImgs]);