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
            %BW = imclose(BW, strel('square',3));
            %BW = imerode(BW, strel('square',2));
            BWsize = size(BW);
            BW = imresize(BW, [100 200]);
            BW = imclose(BW, strel('square',2));
            BW_areaopen = bwareaopen(BW, 200, 4); %bwareaopen(BW, 250, 4); %230
            BW_Filtered = imresize(BW_areaopen, BWsize);
        end
		
    end% methods
end% classdef