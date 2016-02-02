classdef vvPostproc
%VVPREPROC do image post-processing
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
    methods (Static)
		function BW_Filtered = filterBw(BW)
			%BW_imclose = imclose(BW, strel('square', 5)); %imdilate imclose imopen
            BW_areaopen = bwareaopen(BW, 230, 4);
            BW_Filtered = BW_areaopen;
        end
		
    end% methods
end% classdef