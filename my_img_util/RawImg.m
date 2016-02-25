classdef RawImg<handle
    %     I = Img('circuit.tif');
    
    %% Public properties
    properties (GetAccess = public, SetAccess = private)
        path,name,ext
        data
        rows,cols,chns
        roi
    end
    
    %% Public methods
    methods (Access = public)
        
        function I = RawImg(ImageFile)
            [I.path,I.name,I.ext] = fileparts(ImageFile);
            I.data = imread(ImageFile);
            [I.rows, I.cols, I.chns] = size(I.data);
        end
        
        % selrows
        % selcols
        function ROI = rectroi(I, rect) % rectroi({rows, cols}) cannot use []
            ROI = I.data(rect{:}, :);
            I.roi = rect;
            % obj.roi = axes('position',[0.1,0.1,0.4,0.4]);
        end
        
        function h = imshow(I, varargin)
            % TODO resize downsample cases
            %move axis oxy to oxy of roi, for ploting obj in roi
            if isempty(I.roi)
				disp ok
                h = imshow(I.data, varargin{:});
            else
                xdata = [1 I.cols] - I.roi{2}(1);
                ydata = [1 I.rows] - I.roi{1}(1);
                h = imshow(I.data, 'Xdata',xdata, 'Ydata',ydata, varargin{:});
            end
        end
		
		%% TODO: imoverlay(ROI, Edge, [255, 255, 0])
        
        % 		function ROI = selroi(I, roi)
        % 		% not finished yet
        % 			if nargin == 0
        % 			%TODO
        % 			end
        %
        % 			switch class(roi)
        % 				case 'char'
        % 					switch lower(roi)
        % 						case 'lowhalf'
        % 						%TODO if rawimag is gray
        % 							ROI = I.data(ceil(end/2):end, :, :);
        % 						end
        % 					end
        % 				case 'matlab.graphics.primitive.Rectangle'
        % 					% h = rectangle;
        % 			end
        % 		end
        
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