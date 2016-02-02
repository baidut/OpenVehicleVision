classdef vvIPM
%VVIPM perform inverse perspective mapping 
%   Project website: https://github.com/baidut/openvehiclevision
%   Copyright 2016 Zhenqiang Ying.

    %% Public properties
    % properties (GetAccess = public, SetAccess = private)
    % end
 
    %% Static methods
    methods (Static)
	% 'FillValues', 0.8*median(srcImg(nRow,:))
		function TopViewImg = proj2topview(srcImg, movingPoints, rectSize, varargin) 
		% rectSize [nOutCol/width, nOutRow/height]
		    nOutCol = rectSize(1); nOutRow = rectSize(2); % size of rectangle
			fixedPoints = [1, 1; nOutCol,1; nOutCol, nOutRow; 1,nOutRow];
			tform = fitgeotrans(movingPoints, fixedPoints, 'projective');
			TopViewImg = imwarp(srcImg, tform, 'OutputView', ...
			   imref2d([nOutRow, nOutCol]));
		end
		%% plots
%     MovingPointsSelection = figure;imshow(RawImg);impoly(gca, movingPoints);
%     axis auto;%axis([endRowPointL(1) endRowPointR(1) 1 nRow]);
%     saveeps(MovingPointsSelection, RoadFace_ROI);

%% plot results.
% in detail

% test
% imref2d([nOutRow, nOutCol],[1 4*nOutRow],[1 nOutCol])
% imref2d(imageSize,xWorldLimits,yWorldLimits)

% dump ground truth	
% GroundTruth = imread('RIMG00021.pgm');
% GTBirdView = imwarp(GroundTruth, tform);

    end% methods
end% classdef