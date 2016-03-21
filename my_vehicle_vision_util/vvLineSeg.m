classdef vvLineSeg
    %VVLINESEG extract line segments
	% by 
	% LocalHogh - local hough (size of a segment)
	% Radon Transform
	% EDLine - ED line
	% LSD - LSD: a Line Segment Detector
    %
	% return
	% LineObj
	%
    %   Example
    %   -------
    %
    %   Project website: https://github.com/baidut/openvehiclevision
    %   Copyright 2016 Zhenqiang Ying.
    
    %% Public properties
    % properties (GetAccess = public, SetAccess = private)
    % end
    
    %% Static methods
    
    %% Superpixel
    methods (Static)
		function demo(image)
			if nargin < 1
				image = imread('circuit.tif');
			end
			
			smoothingSigma = Slider([0 5]);
			EDLines = ImCtrl(@vvLineSeg.EDLines, I, smoothingSigma);
			
			direction = Popupmenu({'both','horizontal','vertical'});
			%sigma = Slider([0 0.2]);
			thinning = Popupmenu({'thinning','nothinning'});
			
			Prewitt = ImCtrl(@edge, I, 'prewitt', thresh, direction, thinning);
			Roberts = ImCtrl(@edge, I, 'roberts', thresh, thinning);

            F = Fig;
            F.maximize();
			F.subimshow(I, Sobel, Prewitt, Roberts);
		end
		
		function Iseg = LocalHogh(I)
			
        end
		
		function [lineSegments, noLines] = EDLines(image, smoothingSigma)
			dim = size(image);

			temp = EDLinesmex(image, dim(1), dim(2), smoothingSigma);
			noLines = size(temp, 2);

			lineSegments = repmat(LineObj([0 0],[0 0]), noLines, 1);

			for i = 1:noLines
				lineSegments(i) = LineObj([temp(5,i), temp(4,i)], [temp(7,i), temp(6,i)]);
			end
        end
		
		function Radon()
		
		end
        
    end% methods
end% classdef
