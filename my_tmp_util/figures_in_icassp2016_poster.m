%% This script outputs the figure in the poster of my ICASSP2016 paper:
%  Robust Lane Marking Detection using Boundary-Based Inverse Perspective Mapping
% (Zhenqiang Ying & Ge Li) in IEEE-ICASSP2016
% (IEEE International Conference on Acoustics, Speech and Signal Processing 2016) conference.
%
% Email: yinzhenqiang # gmail.com
% Website: https://github.com/baidut/openvehiclevision

%% Contribution 1: S2 Feature

% files = '%datasets\roma\BDXD54\*.jpg';
% images = foreach_file_do(files,@imread);

files = { ...
    '%datasets\roma\LRAlargeur26032003\IMG00579.jpg' ...
    '%datasets\roma\LRAlargeur26032003\IMG01542.jpg' ...
    '%datasets\roma\LRAlargeur26032003\IMG00946.jpg' ...
    '%datasets\roma\BDXD54\IMG00002.jpg' ...
    '%datasets\roma\BDXD54\IMG00030.jpg' ...
    '%datasets\roma\BDXD54\IMG00164.jpg' ...
  };  
images = cellfun(@imread, files, 'UniformOutput',false);
HSV = cellfun(@rgb2hsv, images, 'UniformOutput',false);
H = cellfun(@(hsv)(hsv(:,:,1)), HSV, 'UniformOutput',false);
S = cellfun(@(hsv)(hsv(:,:,2)), HSV, 'UniformOutput',false);
S2 = cellfun(@vvFeature.S2, images, 'UniformOutput',false);

% gray2rgb to fit the size

% fig_S2 = [images,H,S,S2];

figure, montage(cat(4,images{:}),'Size',[1 NaN]);
imwrite(getimage(gca),'figure_s2-1.jpg');
fig_S2 = [H,S,S2];
figure, montage(cat(4,fig_S2{:}),'Size',[3 NaN]);
imwrite(getimage(gca),'figure_s2-2.jpg');

foreach_file_do(files,@dualLaneDetector);