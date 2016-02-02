classdef vvThresh
%VVFEATURE do binarization
% a color/grayscale image ---> a binary image
%
%   Example
%   -------
%   %  Call static methods. (otsu)
%      colorImage = imread('K:\Documents\MATLAB\dataset\roma\BDXD54\IMG00006.jpg');
%      grayImage = colorImage(:,:,1);
%      BW = vvThresh.otsu(grayImage);
%      imshow(BW);
		
    %% Public properties
    % properties (GetAccess = public, SetAccess = private)
    % end
 
    %% Static methods
    methods (Static)
		function BW = otsu(GrayImg)
		    BW = im2bw(GrayImg, graythresh(GrayImg));
		end
		
    end% methods
end% classdef