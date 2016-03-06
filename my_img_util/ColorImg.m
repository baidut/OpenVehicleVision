classdef ColorImg<handle
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
			for n = 1:I.chns
				varargout{n} = func(I.data(:,:,n));
			end
		end
		
		function h = imshow(I, varargin)
            h = imshow(I.data, varargin{:});
			title(inputname(1),'Interpreter','none');
        end

    end% methods
end% classdef