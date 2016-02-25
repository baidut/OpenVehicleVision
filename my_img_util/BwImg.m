classdef BwImg
% Black and White Image / Binary Image
% B         W
    
    %% Public properties
    properties (GetAccess = public, SetAccess = private)
        data
    end
    
    %% Public methods
    methods (Access = public)
	
		function obj = BwImg(data)
		%TODO: check is logical
			obj.data = data;
		end
		
		% rewrite the imshow methods
        function h = imshow(obj, varargin)
			h = imshow(obj.data, varargin{:});
        end
		
		function bwImg = bound(obj, varargin)
			bw = bwperim(obj.data, varargin{:});
			bw([1,end],:) = 0;
			bw(:,[1,end]) = 0;
			bwImg = BwImg(bw);
		end
		
    end% methods
end% classdef