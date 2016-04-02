
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


