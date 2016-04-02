function [  ] = test_road_area_detection(algo)
%TEST_ROAD_AREA_DETECTION Summary of this function goes here
%   Detailed explanation goes here

% ii_method = @(x)dualLaneDetector.rgb2ii(x, 0.2*255);
% algo = @(im)dualLaneDetector.roadDetectionViaIllumInvariant(im,ii_method);

%% !!!!!!!!!!!!!!!
if nargin < 1
    algo = @(im)road_detection_via_ii(im,@dualLaneDetector.rgb2ii_ori, {0.08});
end

% algo = @(im)road_detection_via_ii(im,0.2*255);

%% Good cases
% BDXD54 % IMG00106 IMG00002 IMG00164
imgFile = '%datasets\roma\BDXD54\IMG00106.jpg'; 
%% Fail cases
% \IRC04510\IMG00075 % IMG00075
% \IRC041500\IMG00322
% \RD116\imd00773  under bidge
% \RouenN8IRC051900\IMG00007
% \LRAlargeur13032003\IMG01480
% \RouenN8IRC052310\IMG01339

% imgFile = '%datasets\roma\IRC04510\IMG00075.jpg'; 
% imgFile = '%datasets\roma\LRAlargeur13032003\IMG01513.jpg';  % IMG01771 IMG01513 IMG01480
% imgFile = '%datasets\roma\RouenN8IRC052310\IMG00915.jpg';  %  IMG01339 IMG01545 IMG00915
rawImg = imread(imgFile);

%% Note: we do impyramid to acc speed
rawImg = impyramid(rawImg,'reduce');
rawImg = impyramid(rawImg,'reduce');

gtImg = imread(RomaDataset.roadAreaGt(imgFile));
gtImg = impyramid(gtImg,'reduce');
gtImg = impyramid(gtImg,'reduce');

roiOf = @(x)x(ceil(end/3):end,:,:); % ceil(end/2)

roiImg = roiOf(rawImg);
gt = roiOf(gtImg);

result = algo(roiImg);

eval = ConfMat({result},{gt},1);
% imshow(roiImg/3+eval.mask{1});
disp(eval);

% imshow(eval.mask{1})

end

%{
func = @(f)imwrite(dualLaneDetector.rgb2ii(imread(f), 0.2*255), [f '_ii2.tif']);
foreach_file_do('%datasets\roma\BDXD54\*.jpg',func);

% ori is better
func = @(f)imwrite(dualLaneDetector.rgb2ii_ori(imread(f), 0.2), [f(1:end-4) '_ii.tif']);
foreach_file_do('%datasets\roma\BDXD54\*.jpg',func);


foreach_file_do('%datasets\roma\BDXD54\*.tif',@delete);

save('%mat/otsu_ii_eval.mat', 'ii_otsu')
%}


% otsu can hanle 99.6% cases (112/117) but perform very bad in other 0.04%
% compare with other ii method and gray commponent