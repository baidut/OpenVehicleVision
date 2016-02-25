classdef dualLaneDetector<handle
% foreach_file_do('F:\Documents\pku-road-dataset\1\EMER0009\0*.jpg', @dualLaneDetector);
% 0720

    %% Public properties
    properties (GetAccess = public, SetAccess = private)
    end
    
    methods (Access = public)
        % 'F:\Documents\pku-road-dataset\1\EMER0009\0379.jpg'
        function obj = dualLaneDetector(imgFile)
            Raw = RawImg(imgFile);%0289
            %TODO: below the horizon
            ROI = Raw.rectroi({ceil(Raw.rows/2):Raw.rows,1:Raw.cols});
            
            %% Segmentation
            % vvSeg.felzen(ROI);
            ISeg = vvSeg.felzen(ROI,3);
            RoadFace = ISeg.maxarea();
            
            %% Road Bound Edge
            RoadBound = RoadFace.bound(8);
            % implot(ROI, ISeg, RoadFace, imoverlay(ROI, RoadBound.data, [255, 255, 0]));
            % return;
            %% line detection
            Edge = RoadBound.data;
            boundAngleRange = 30:75;
            
            BoundL = vvBoundModel.houghStraightLine(Edge, boundAngleRange); % 0:89
            BoundR = vvBoundModel.houghStraightLine(Edge, -boundAngleRange); % -89:0
            
            Raw.roidrawmask(RoadFace.data);
            imshow(Raw);
            %plotpoint(Edge);% TODO: remove plotpoint, 
            BoundL.plot('r');
            BoundR.plot('g');
            
%             saveas(gcf, ['%Temp/', Raw.name, '.jpg']); 
%             close(gcf);
        end
    end
end