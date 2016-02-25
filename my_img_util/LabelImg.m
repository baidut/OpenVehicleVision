classdef LabelImg
    
    %% Public properties
    properties (GetAccess = public, SetAccess = private)
        data
    end
    
    %% Public methods
    methods (Access = public)
	
		function obj = LabelImg(data)
			obj.data = data;
		end
		
		% rewrite the imshow methods
        function h = imshow(obj, varargin)
			h = imshow(label2rgb(obj.data), varargin{:});
        end
        
    end% methods
end% classdef