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
            rHorizon = ceil(Raw.rows/2);
            ROI = Raw.rectroi({rHorizon:Raw.rows,1:Raw.cols});
            
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
            RoadFace = imfill(RoadFace,'holes');
            RoadBound = BwImg.bound(RoadFace);
            
            
            %% line detection
            boundAngleRange = 30:75;
            
            BoundL = vvBoundModel.houghStraightLine(RoadBound, boundAngleRange); % 0:89
            BoundR = vvBoundModel.houghStraightLine(RoadBound, -boundAngleRange); % -89:0
            
            Result = Raw.roidrawmask(RoadFace); % Img + mask (+g, -b, -r) use mean
            
            Marking = dualLaneDetector.getLaneMarking(ROI, RoadFace);
            
            line = vvBoundModel.houghStraightLine(Marking, -70:70);
            
           
            
            %% Display results
            Fig.subimshow(Raw,Result,RoadFace, Marking); % Marking RoadFace
            selplot(1);
            %plotpoint(Edge);% TODO: remove plotpoint,
            BoundL.plot('r', 'LineWidth' , 5);
            BoundR.plot('g', 'LineWidth' , 5);
            
            if isempty(line)
                disp('Fail in lane markings detection.');
            else
                nRow = size(ROI,1);
                PointS = [line.row(1), 1]; % start point
                PointE = [line.row(nRow), nRow]; % end point
                lineMarking = LineObj(PointS, PointE);
                
                % Plot
                lineMarking.plot('LineWidth',3,'Color','blue');
            end
            
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
        
        function Marking = getLaneMarking(ROI, roadFaceMask)
            % roi is a rgb image
            % roadFaceMask is a bw (1: road, 0: non-road)
            [nRow, nCol, ~] = size(ROI);
            V_ROI = im2double(max(ROI, [], 3)); % Note!
            I2 = zeros(nRow, nCol);
            
            s_max = 50;
            
            for r = 1 : nRow
                mw = ceil(s_max * r / nRow); % marking width
                for c =  (1 + 5*mw):(nCol-5*mw)
                    I2(r, c) = 2*V_ROI(r,c) - (V_ROI(r,c-mw) + V_ROI(r,c+mw)) ...
                        - abs(V_ROI(r,c-mw) - V_ROI(r,c+mw));
                end
            end
            
            if nargin > 1
                I2(~roadFaceMask) = 0;
                Marking = im2bw(I2, graythresh(I2(roadFaceMask)));
            else
                Marking = im2bw(I2, graythresh(I2(I2~=0)));
            end
        end
        
        function dtLaneMarking(Img,rHorizon,cBoundaryL,cBoundaryR,thetaSet)
            
            %%  Region of interest adjustment
            %ROI = Img(rHorizon:end,:,1);
            ROI = Img(rHorizon:end,:,:);
            
            %%  Lane-marking feature extraction
            Marking = dualLaneDetector.getLaneMarking(ROI,cBoundaryL,cBoundaryR);
            
            %% Lane model fitting
            line = vvBoundModel.houghStraightLine(Marking, thetaSet);
            
            if isempty(line)
                disp('Fail in lane markings detection.');
            else
                PointS = [line.row(1), rHorizon]; % start point
                PointE = [line.row(nRow), nRow+rHorizon]; % end point
                lineMarking = LineObj(PointS, PointE);
                
                % Plot
                lineMarking.plot('LineWidth',3,'Color','red');
            end
        end
    end
end