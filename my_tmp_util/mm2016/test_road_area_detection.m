function [  ] = test_road_area_detection(  )
%TEST_ROAD_AREA_DETECTION Summary of this function goes here
%   Detailed explanation goes here

ii_method = @(x)dualLaneDetector.rgb2ii(x, 0.2*255);
algo = @(im)dualLaneDetector.roadDetectionViaIllumInvariant(im,ii_method);

% algo = @(im)road_detection_via_ii(im,0.2*255);

imgFile = '%datasets\roma\BDXD54\IMG00106.jpg'; % IMG00106 IMG00002 IMG00164
rawImg = imread(imgFile);
gtImg = imread(RomaDataset.roadAreaGt(imgFile));

roiOf = @(x)x(ceil(end/2):end,:,:);
roiImg = roiOf(rawImg);
gt = roiOf(gtImg);

result = algo(roiImg);

eval = ConfMat({result},{gt},1);
imshow(roiImg/3+eval.mask{1});
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