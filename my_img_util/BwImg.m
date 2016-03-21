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
            bw = bwperim(+obj, varargin{:});
            bw([1,end],:) = 0;
            bw(:,[1,end]) = 0;
            % class(bw) logical
            bw = BwImg(bw);
        end
        
        function colorImg = tocolor(obj, color)
            % Do not support multi-channel image
            if nargin < 2
                color = [255 255 255]; % scalar doubles
            end
            colorImg = cat(3, obj.data*color(1), obj.data*color(2), obj.data*color(3));
            % class(colorImg) double
            colorImg = ColorImg(uint8(colorImg));
        end
        %% get value
        function value = uplus(obj)
            value = obj.data;
        end
    end
    methods (Static)
        
        function bw = boundOf(obj, varargin)
            bw = bwperim(+obj, varargin{:});
            bw([1,end],:) = 0;
            bw(:,[1,end]) = 0;
        end
        
        % test case
        % I = BwImg(imread('text.png'));
        % imshow(I.maxarea(+I));
        % 
        function bw = maxarea(obj) % input can be an obj or bw image.
        % http://cn.mathworks.com/help/images/ref/bwconncomp.html
            bw = false(size(+obj));
            CC = bwconncomp(+obj); % support BwImg

            numPixels = cellfun(@numel,CC.PixelIdxList);
            [~,idx] = max(numPixels);
            bw(CC.PixelIdxList{idx}) = 1;

		% max connected area
        % http://stackoverflow.com/questions/22514668/select-largest-object-in-an-image
        % labeled image
		% http://stackoverflow.com/questions/20725603/how-to-select-the-object-with-the-largest-area
% 			L = bwlabel(+obj, 4);
%             
%             % call label image's maxarea
%             stat = regionprops(L,'Centroid','Area','PixelIdxList');
% 			[~,index] = max([stat.Area]);
%             
% 			bw = (+obj == index);
        end
        % for object
        % obj.data = obj.maxarea();
        
        function bw = dilate(obj)
            se = strel('ball',5,5);
            bw = imdilate(+obj, se);
        end
        
        function bw = erode(obj)
            se = strel('ball',5,5);
            bw = im(+obj, se);
        end
    end% methods
end% classdef