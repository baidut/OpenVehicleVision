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
        
        function colorImg = tocolor(obj, color)
            % Do not support multi-channel image
            if nargin < 2
                color = [255 255 255];
            end
            colorImg = cat(3, obj.data*color(1), obj.data*color(2), obj.data*color(3));
            colorImg = ColorImg(colorImg);
        end
    end% methods
end% classdef