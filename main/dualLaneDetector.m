classdef dualLaneDetector<handle
% foreach_file_do('E:\Documents\pku-road-dataset\1\EMER0009\0*.jpg', @dualLaneDetector);
%{
AfterRain = vvDataset('%datasets\nicta-RoadImageDatabase\After-Rain');
files = AfterRain.filenames('*.tif');
 cellfun(@dualLaneDetector, files, 'UniformOutput',false);
%}
% 
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
            
            %% Preproc:Filtering road marking
            % may smooth the road boundary either
            
            % do filter on R, G, B then cat
            % img.eachchn()
%             LT = vvMark.rowFilter(ROI, @vvMark.LT);
%             MLT = vvMark.rowFilter(ROI, @vvMark.MLT);
%             SMLT = vvMark.rowFilter(ROI, @vvMark.SMLT);
%             Fig.subimshow(ROI,LT,MLT,SMLT);
            
%             Size = Uiview('slider','min',0,'max',1,'value',0.1);
%             SMLT = Uictrl(@vvMark.rowFilter, ROI, @vvMark.SMLT, Size);
%             Fig.subimshow(ROI,SMLT);

%             SMLT = vvMark.rowFilter(ROI,@vvMark.SMLT,0.3);
%             ROI = SMLT;
            
            %% Segmentation
%             vvSeg.felzen(ROI);return;
            ISeg = vvSeg.felzen(ROI,3,200,50);%200
            % too mush sigma will loose small details
            % sigma bigger smooth, k smaller 
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
            
            Result = Raw.roidrawmask(RoadFace.data);
            Fig.subimshow(Raw,Result,ROI,ISeg);
            selplot(2);
            %plotpoint(Edge);% TODO: remove plotpoint, 
            BoundL.plot('r');
            BoundR.plot('g');
            
            saveas(gcf, ['%Temp/', Raw.name, '.jpg']); 
            close(gcf);
        end
    end
end