classdef ColorImg<handle
    %TODO: add imadd imsub overwrite
	% Multi-Channel Image.
    
    %% Public properties
    properties (GetAccess = public, SetAccess = private)
        data
        rows,cols,chns
    end
    
    %% Public methods
    methods (Access = public)
        
        function I = ColorImg(Image)
			I.data = Image;
            [I.rows, I.cols, I.chns] = size(I.data);
        end
		
		function [varargout] = eachChn(I, func)
		% I = RawImg('peppers.png');
		% [R G B] = I.eachChn();
		% Fig.subimshow(I, R, G, B);
			if nargin < 2
				func = @(x)x;
			end
			
			%no need to use arrayfun since the #chn is not big
            varargout = cell(I.chns,1);
			for n = 1:I.chns
				varargout{n} = func(I.data(:,:,n));
            end
        end
		
		function h = imshow(I, varargin)
            h = imshow(I.data, varargin{:});
			title(inputname(1),'Interpreter','none');
        end
		
		function c = plus(a,b)
			c = ColorImg(imadd(a.data, b.data));
		end
		
		function c = minus(a,b)
			c = ColorImg(imsubtract(a.data, b.data));
		end
		
		function c = uminus(a)
			c = ColorImg(imcomplement(a.data));
			% if c == a, delete a?
		end
		
		function c = times(a)
			c = ColorImg(immultiply(a.data, b.data));
		end
    end% methods
end% classdef