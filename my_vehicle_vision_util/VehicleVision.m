
classdef VehicleVision

    properties
        filenames
        tracking
    end
 
    methods
        function obj = VehicleVision(imList, varargin)
            % imList
            % a string specifying the list of images. 
            % 
            % USER CONFIGURABLE OPTIONS
            %
            % Possible param/value options are:
            % Supported specifications:
            % 'tacking'         - true to enable tracking module. Note the images should 
            %                     have same size and be sorted by time when tracking is on. 
        	% 'displayLevel'   -  determine how much information to be displayed. (default is 1)
        	%                     0 : no display, only output result to file (release)
            %                     1 : errors
        	%                     2 : + warnings
        	%                     3 : + show main figure (debug, time consuming)
            %                     4 : + output intermediate results (when encountering bugs)
        	%                     5 : + progression (progressbar)
        	%                     6 : + information (disp more information)
        	p = inputParser;
        	addRequired(p,'imList',@isstr);
		   	addOptional(p,'displayLevel', 1,@isnumeric); 
            addOptional(p,'tracking', false,@isnumeric);
		   	addOptional(p,'learning', false,@isnumeric);
		   	parse(p,imList,varargin{:});

            data=textread(name,'%s','delimiter','\n','whitespace','');
            nelem = str2num(char(data(1)));% first line of the file specify the number of elements.
            filenames=data(2:nelem+1);
		   	
		   	obj.tracking = p.Results.tracking;
		   	obj.displayLevel = p.Results.displayLevel;
            

            % initalize: accuracy is more important than speed.
            [Sky, Support, Vertical] = analyse3dLayout(filenames(1));

            %% boundary detection using a more sophisticated boudary feature map


        end

        function processing(obj)
            infor = null;
            for n = 1:length(filenames)
                
                I = imread(filenames(n));

                % init the parameters.
                if obj.tracking

                else

                end 

                % Boundary feature extraction
                for i = 1 : 2 % two road region
                    f = vvGetFeature(RoadRegion(i), 'S2');
                    f = imclose();
                end

                % Boundary points extraction

                if ~obj.tracking
                    infor = null;
                end
            end
        end

    end% methods
end% classdef


% old pattern: output = function(input, method)
% new pattern: pipeline(S2FeatureExtractor, BoundMarker, LineFitter, ViewConverter)