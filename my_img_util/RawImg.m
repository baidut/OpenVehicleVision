classdef RawImg
%     I = Img('circuit.tif');
    
    %% Public properties
    properties (GetAccess = public, SetAccess = private)
        path,name,ext
        data
        rows,cols,chns
        
    end
    
    %% Public methods
    methods (Access = public)
        
        function I = Img(ImageFile)
            [I.path,I.name,I.ext] = fileparts(ImageFile);
            I.data = imread(ImageFile);
            [I.rows, I.cols, I.chns] = size(I.data);
        end
        
        function h = plot(I, varargin)
            h = imshow(I.data, varargin{:});
            title(inputname(1));
        end
        
        function bool = isgray(I)
            bool = (I.chns == 1);
        end
		
        % plot and draw
        % plot over can be removed while draw will change image data.
		% plot is not the responsibility of this obj (axes, figure)
		% draw 
        
        function imdata = drawLine(I, lineObj)
        end
        
    end% methods
end% classdef