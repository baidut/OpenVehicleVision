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
        function self = dualLaneDetector(imgFile)
            %% settings
            med_size = [10 10];
            
            Raw = RawImg(imgFile);%0289
            %TODO: below the horizon
            
            %% ROI selection
            ROI = Raw.rectroi({ceil(Raw.rows/2):Raw.rows,1:Raw.cols});
            
            %% Shadow Removal
            ShadowFreeImage = self.rgb2ii(ROI);
            GraySmooth = medfilt2(ShadowFreeImage,med_size);
            %% Segmentation
            Bw = vvThresh.otsu(GraySmooth);
%             Bw = im2bw(GraySmooth, graythresh(GraySmooth)+0.15); 
            %% Remove Noise
            % imguidedfilter: bad performance
            %RoadSmooth = imguidedfilter(Road);
            %imshowpair(Road,RoadSmooth,'montage');
            
            %% just get the max conn area
            %RoadSmooth = bwareaopen(~Road, 50, 8);
            %RoadSmooth = bwareaopen(Road, 500, 8);% BwImg.dilate(Road);
            RoadSmooth = medfilt2(Bw,med_size);
            RoadFace = BwImg.maxarea(RoadSmooth);
            RoadBound = BwImg.bound(RoadFace);
            
            
            %% line detection
            boundAngleRange = 30:75;
            
            BoundL = vvBoundModel.houghStraightLine(RoadBound, boundAngleRange); % 0:89
            BoundR = vvBoundModel.houghStraightLine(RoadBound, -boundAngleRange); % -89:0
            
            Result = Raw.roidrawmask(RoadFace); % Img + mask (+g, -b, -r) use mean
            Fig.subimshow(Raw,Result,ROI, RoadFace);
            selplot(2);
            %plotpoint(Edge);% TODO: remove plotpoint,
            BoundL.plot('r');
            BoundR.plot('g');
            
%             saveas(gcf, ['%Temp/', Raw.name, '.jpg']);
%             close(gcf);
            
            
%             Fig.subimshow(Raw, ShadowFreeImage, GraySmooth, Bw, RoadArea, RoadBound);
%             maxfig;
            return;
            
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
            
        end
    end
    %% Algorithm that can be used in the future
    methods (Static)
        function ii_image = rgb2ii(image)
            [~, G, B] = getChannel(im2double(image));
            ii_image =  1-(G+0.2-B)./B;
            ii_image(ii_image<0) = 0;
        end
    end
end