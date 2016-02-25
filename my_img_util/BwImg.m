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
		
		function bw = bound(obj, varargin)
			bw = BwImg(bwperim(obj.data, varargin{:}));
		end
		
    end% methods
end% classdef