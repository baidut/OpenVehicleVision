
%% Show video
%{
src = '%datasets\nicta-RoadImageDatabase\Sunny-Shadows\*.tif';

% imgFile = foreach_file_do(src,@(x)x);
rawImg = foreach_file_do(src,@imread); %slow
rawImg = cellfun(@(im)impyramid(im,'reduce'),rawImg,'UniformOutput',false);

grayImg = cellfun(@(im)im2double(rgb2gray(im)),rawImg,'UniformOutput',false);
invariant = cellfun(@(im)GetInvariantImage(im,36,0,1), rawImg,'UniformOutput',false);
will2014 = cellfun(@(im)rgb2ii.will2014(im,.42), rawImg,'UniformOutput',false);
ours = cellfun(@(im)dualLaneDetector.rgb2ii(im,256*.06),rawImg,'UniformOutput',false); % .05 .10 is too dark

% very slow
% frame = [cat(3,grayImg{:}) cat(3,invariant{:}); ...
%          cat(3,will2014{:}) cat(3,ours{:})];
% Error using horzcat
% Out of memory. Type HELP MEMORY for your options. 
grayVid = cat(3,grayImg{:}); % slow, very fast after downsample
invaVid = cat(3,invariant{:});
willVid = cat(3,will2014{:});
oursVid = cat(3,ours{:});
implay([grayVid invaVid;...
        oursVid willVid]);
%}    
%% KITTI
% for kitti need to inverse

% image size is not unique in kitti
% src = '%datasets\KITTI\data_road\training\image_2\*.png';
% rawImg = foreach_file_do(src,@imread); 

src = vvDataset('%datasets\KITTI\data_road\training\image_2\');
rawImg = src.imgsarray('*.png');

rawImg = arrayfun(@(im)impyramid(im,'reduce'),rawImg,'UniformOutput',false);
rawImg = arrayfun(@(im)impyramid(im,'reduce'),rawImg,'UniformOutput',false);

grayImg = arrayfun(@(im)im2double(rgb2gray(im)),rawImg,'UniformOutput',false);
alvarez2011 = arrayfun(@(im)rgb2ii.alvarez2011inv(im,.6), rawImg,'UniformOutput',false);
will2014 = arrayfun(@(im)rgb2ii.will2014inv(im,.53), rawImg,'UniformOutput',false);
ours = arrayfun(@(im)dualLaneDetector.rgb2ii_ori(im,.06),rawImg,'UniformOutput',false); % .05 .10 is too dark

% very slow
% frame = [cat(3,grayImg{:}) cat(3,invariant{:}); ...
%          cat(3,will2014{:}) cat(3,ours{:})];
% Error using horzcat
% Out of memory. Type HELP MEMORY for your options. 
% grayVid = cat(3,grayImg{:}); % slow, very fast after downsample
% invaVid = cat(3,alvarez2011{:});
% willVid = cat(3,will2014{:});
% oursVid = cat(3,ours{:});

frames = [grayImg ;alvarez2011;...
        ours ;will2014];
implay(frames);

v = VideoWriter('%results/ii_kitti.mp4');

for k = 1:size(frames,3)
   frame = frames(:,:,k);
   writeVideo(v,frame);
end

close(v);

