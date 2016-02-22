classdef Img
%     I = Img('circuit.tif');
%     I.getname()
    
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
        
        function h = plot(I)
            h = imshow(I.data);
            title(inputname(1));
        end
        
        function bool = isgray(I)
            bool = (I.chns == 1);
        end
        
        function ratio = plotLane(I)
        end
        
        function [pointsM, labeled] = drawLine(I, ratio)
        end
        
    end% methods
end% classdef