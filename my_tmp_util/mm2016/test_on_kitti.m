function [ output_args ] = test_on_kitti(  )
%TEST_ON_KITTI Summary of this function goes here
%   Detailed explanation goes here
% tune;return
test_road_area_detection(@(rgb)ii_help_seg(rgb,1.5,600,1000));
% 1.1029,770.6248,353.3528
% 0.5,688.3749,432.6322
end

function res = ii_help_seg(rgb, sigma, k, min)
    
    %% improve
    gray = rgb2ii_2d(rgb,.2*255); %im2double(rgb2gray(rgb));
    ii = repmat(im2uint8(gray), [1 1 3]);
    
    label = vvSeg.felzen(ii, sigma, k, min); %0.5, 600, 300);
    
%     res = label2rgb(label.data);return;
    
    RoadFace = label.maxarea();
    Fig.subimshow(rgb, RoadFace);
    res = RoadFace.data;
%     res = label2rgb(label.data);
%     imwrite(res,'%results/seg/seg_via_ii.png');
end

function tune()
%     inputImage = ImCtrl(@imread, FilePick());
    inputImage = imread('%datasets\roma\BDXD54\IMG00164.jpg'); 
    inputImage = impyramid(inputImage,'reduce');
    inputImage = impyramid(inputImage,'reduce');
    inputImage = inputImage(ceil(end/3):end,:,:); % ceil(end/2)
    sigma = Slider([0 3]);
    k = Slider([1 800]);
    min = Slider([1 8000]);
    RoadFace = ImCtrl(@ii_help_seg, inputImage, sigma, k, min);
    Fig.subimshow(inputImage, RoadFace);
    
    % smaller K, more clusters classes,
    % sigma is used to smooth
    % min is min area size
end

