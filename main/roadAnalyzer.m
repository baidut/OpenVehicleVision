classdef roadAnalyzer<handle
% roadAnalyzer display road detection result of the image file
% specified by the string FILENAME. 
% Based on the static road scene image, the algorithm extract two road 
% boundaries and middle lane-marking using straight line model.
%
% This code is the implementation of the approach proposed in the paper 
% "An Illumination-Robust Approach for Feature-Based Road Detection" 
% (Zhenqiang Ying, Ge Li & Guozhen Tan) to appear in IEEE-ISM2015
% (IEEE International Symposium on Multimedia 2015) conference.
%
%   Example
%   -------
%   Test on Roma dataset.
%      roma_BDXD54 = 'F:\Documents\MATLAB\dataset\roma\BDXD54\*.jpg';
%      figs = foreach_file_do(roma_BDXD54, @roadDetection);
%
%   Project website: https://github.com/baidut/openvehiclevision
%   Copyright 2015 Zhenqiang Ying.

    %% Public properties
    properties (GetAccess = public, SetAccess = private)
        
    end
    
    methods (Access = public)
        % 'F:\Documents\pku-road-dataset\1\EMER0009\0379.jpg'
        function obj = roadAnalyzer(imgFile)
            
            Raw = RawImg(imgFile);%0289
            
        end
        
        function init()
            
        end
    end
end