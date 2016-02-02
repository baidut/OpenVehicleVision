classdef vvPreproc
%VVPREPROC do image pre-processing
%
%   Example
%   -------
%   %  Call static methods.
%      I = imread('K:\Documents\MATLAB\dataset\roma\BDXD54\IMG00006.jpg');
%      J = vvPreproc.deblock(I);
%      imshow(J);
%
%   Project website: https://github.com/baidut/openvehiclevision
%   Copyright 2016 Zhenqiang Ying.
		
    %% Public properties
    % properties (GetAccess = public, SetAccess = private)
    % end
 
    %% Static methods
    methods (Static)
		function ImgProc = deblock(ImgRaw)
			ImgProc = imgaussfilt(ImgRaw, 2);
		end
		
    end% methods
end% classdef