classdef roadAnalyzer<handle
% roadAnalyzer 
%
%   Project website: https://github.com/baidut/openvehiclevision
%   Copyright 2016 Zhenqiang Ying.

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