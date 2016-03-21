classdef test
    methods
        function obj = test()
        end
    end
    methods (Static)
        function adaptCluster(inputImage)
            if nargin < 1
                inputImage = ImCtrl(@imread, FilePick());
            end
            labelImage = ImCtrl(@segment, inputImage);
            Fig.subimshow(inputImage, labelImage);
            
            function labelImg = segment(rgbImg)
                % ii image need to be filtered before being used.
                rgbImg = rgbImg(ceil(end/2):end,:,:);
                ii_image = dualLaneDetector.rgb2ii(rgbImg, 0.2);
                smoothed = medfilt2(ii_image,[10 10]);% size should be adaptive
                label = adaptcluster_kmeans(smoothed);
                labelImg = label2rgb(label);
            end
        end
    end
    % strong_shadow = imread('D:\Documents\MATLAB\OpenVehicleVision\%datasets\roma\BDXD54\IMG00002.jpg');
    % ('%datasets\nicta-RoadImageDatabase\Sunny-Shadows\261011_p1WBoff_BUMBLEBEE_06102716324102.tif')
end