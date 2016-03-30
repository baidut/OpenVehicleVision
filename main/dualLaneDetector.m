classdef dualLaneDetector<handle
    % foreach_file_do('E:\Documents\pku-road-dataset\1\EMER0009\0*.jpg', @dualLaneDetector);
    %{
AfterRain = vvDataset('%datasets\nicta-RoadImageDatabase\After-Rain');
files = AfterRain.filenames('*.tif');
 cellfun(@dualLaneDetector, files, 'UniformOutput',false);
    
foreach_file_do('%datasets\roma\BDXD54/*.jpg',@(x)dualLaneDetector(x,0.2));
foreach_file_do('%datasets\roma\BDXN01/*.jpg',@(x)dualLaneDetector(x,0.2));
foreach_file_do('%datasets\roma\LRAlargeur13032003/*.jpg',@(x)dualLaneDetector(x,0.11));
    
    %}
    %
    % 0720
    
    %% Public properties
    properties (GetAccess = public, SetAccess = private)
    end
    
    methods (Access = public)
        % 'F:\Documents\pku-road-dataset\1\EMER0009\0379.jpg'
        function self = dualLaneDetector(imgFile, ii_b)
            %% settings
            ii_method = @(x)self.rgb2ii(x, ii_b);  % 0.06 0.2 roma
            
            Raw = RawImg(imgFile);%0289
            
            % resize to improve size (not required)
%             Resized = ColorImg(impyramid(Raw.data, 'reduce'));
            
            %TODO: below the horizon
            
            %% ROI selection
            rHorizon = ceil(Raw.rows/2);
            ROI = Raw.rectroi({rHorizon:Raw.rows,1:Raw.cols});
            
            %% Shadow Removal
            RoadFace = roadDetectionViaIllumInvariant(ROI, ii_method);
%             RoadSegResult = RoadFace;

            %% line detection
            [BoundL, BoundR] = self.straightLineModeling(RoadFace);
%              [BoundL, BoundR] = self.parabolaModeling(RoadFace);
            
            %% Display results
            %{
            Result = Raw.roidrawmask(RoadFace, 'g'); % Img + mask (+g, -b, -r) use mean
            Marking = dualLaneDetector.getLaneMarking(ROI, RoadFace);
            line = vvBoundModel.houghStraightLine(Marking, -70:70);
            
            figure;
            maxfig;
            Fig.subimshow(Raw,Result,ShadowFreeImage, GraySmooth); % rgb2gray(ROI) Marking RoadFace RoadSegResult
            selplot(1);
            %plotpoint(Edge);% TODO: remove plotpoint,
            plot(BoundL{:}, 'r'); %, 'LineWidth' , 5);
            plot(BoundR{:}, 'g'); %, 'LineWidth' , 5);
            
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
            %}
            
            %{
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
            %}
        end
    end
    %% Algorithm that can be used in the future
    methods (Static)
        
        function RoadFace = roadDetectionViaIllumInvariant(ROI, ii_method) % Illum abbr. for illumination
            % TODO: for noise removal, try Relaxation (iterative method) 
            % ii_method: @(x)self.rgb2ii(x, ii_b)  % 0.06 0.2 roma
            
            ShadowFreeImage = ii_method(ROI);
            
            % median filter need time-consuming sorting, especially when
            % window is large
            
            % GraySmooth = wiener2(ShadowFreeImage,[8 8]); % medfilt2
            % RoadFace = dualLaneDetector.getRoadFaceMultiClass(GraySmooth); 
            
%             Label = adaptcluster_kmeans(GraySmooth);
%             RoadFace = LabelImg.maxareaOf(Label);
%             RoadFace = imfill(RoadFace,'holes');
%             RoadSegResult = label2rgb(Label);

            RoadFace = dualLaneDetector.getRoadFaceMultiClass(ShadowFreeImage); 
            % getRoadFace2Class GraySmooth
        end
        
        function ii_image = rgb2ii(image, c)

            
%             [~, G, B] = getChannel(im2double(image));
%             ii_image =  1-(G+c-B)./(B+eps);
%             ii_image(ii_image<0) = 0;
            
% im2double is time-consuming
              [~, G, B] = getChannel(image);
              ii_image =  2 - (double(G+c))./(double(B)+eps);
        end
        
        function ii_image = rgb2ii_ori(image, c)
        %initial version 
            [~, G, B] = getChannel(im2double(image));
            ii_image =  1-(G+c-B)./B;
            ii_image(ii_image<0) = 0;
        end
        
        function ii_image = rgb2ii_eps(image, c)
            [~, G, B] = getChannel(im2double(image));
            ii_image =  1-(G+c-B)./(B+eps);
            % max min
        end
        % replace GB with logG, logB perform badly
        
        function RoadFace = getRoadFace2Class(GraySmooth)
           % two-class will suffer car's interferance
           
            %% Binarization
            bw = vvThresh.otsu(GraySmooth);
            % Bw = im2bw(GraySmooth, graythresh(GraySmooth)+0.15);
            %
            %% Remove noise 
            %
            % imguidedfilter: bad performance
            % RoadSmooth = imguidedfilter(Road);
            % imshowpair(Road,RoadSmooth,'montage');
            %
            % RoadSmooth = bwareaopen(~Road, 50, 8);
            
            bwSmooth = medfilt2(bw, [5 5]);
            bwEroded =  imopen(bwSmooth, strel('disk',8,8));
            
            RoadFace = BwImg.maxarea(bwEroded);
            RoadFace = imfill(RoadFace,'holes');
        end
        
        function RoadFace = getRoadFaceMultiClass(GraySmooth)
            Label = adaptcluster_kmeans(GraySmooth);
            RoadFace = LabelImg.maxareaOf(Label);
            RoadFace = imfill(RoadFace,'holes');
        end
        
        function [BoundL, BoundR] = straightLineModeling(RoadFace)
            RoadBound = BwImg.boundOf(RoadFace);
            boundAngleRange = 30:75;
            
            BoundL = vvBoundModel.houghStraightLine(RoadBound, boundAngleRange); % 0:89
            BoundR = vvBoundModel.houghStraightLine(RoadBound, -boundAngleRange); % -89:0
            
            BoundL = {BoundL};
            BoundR = {BoundR};
        end
        
        function [BoundL, BoundR] = parabolaModeling(RoadFace)
            [xL,yL, xR, yR] = dualLaneDetector.getBoundXY(RoadFace);
            
            pL = polyfit(xL,yL,2);
            pR = polyfit(xR,yR,2);
            
            % note: reverse the x y to fit row column
            % x - column, y - row
            BoundL = {polyval(pL,xL),xL};
            BoundR = {polyval(pR,xR),xR};
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
        
        function [cBoundaryL,cBoundaryR] = getBound(roadFaceMask)
            % r - row
            % c - column
            % a more simple way is find in left and right half
            % independently.
            
            nRow = size(roadFaceMask, 2);
%             cBoundaryL = zeros([1 nRow]);
%             cBoundaryR = zeros([1 nRow]);
%             cLeft = 0;
%             cRight = size(roadFaceMask,1);
%             cMid = (cLeft+cRight)/2;
            for r = nRow:-1:1
                % find first and last non-zero
                c = find(roadFaceMask(r,cLeft:cMid),1,'first');
                if isempty(c)
                    break;
                end
                cBoundaryL(r) = c;
                cBoundaryR(r) = find(roadFaceMask(r,cMid:cRight),1,'last');
                % update
            end
            
            % the data need to be clean and transform to xy locations
            % addPoint
        end
        
        function [XL,YL, XR, YR] = getBoundXY(roadFaceMask)
            % r - row
            % c - column
            % a more simple way is find in left and right half
            % independently.
            
            [nRow, nCol] = size(roadFaceMask);
            rStart = nRow-10;
            rEnd = 1;
%             cBoundaryL = zeros([1 nRow]);
%             cBoundaryR = zeros([1 nRow]);
%             cLeft = 0;
%             cRight = size(roadFaceMask,1);
%             cMid = (cLeft+cRight)/2;
            for r = rStart:-1:1 % last row have noice
                % find first and last non-zero
                c = find(roadFaceMask(r,:),1,'first');
                if isempty(c)
                    rEnd = r;
                    break;
                end
                cBoundaryL(r) = c;
                cBoundaryR(r) = find(roadFaceMask(r,:),1,'last');
                % update
            end
            % the data need to be clean and transform to xy locations
            % addPoint
            
            XL = rStart:-1:rEnd;
            XR = rStart:-1:rEnd;
            
            YL = cBoundaryL(XL);
            YR = cBoundaryR(XR);
            
            %% filtering points
            XL(YL<20) = []; % note do XL first, or YL will change
            YL(YL<20) = [];
            
            XR(YR==nCol) = [];
            YR(YR==nCol) = [];
        end
        
        function func = fitCurve(x)
            % RANSAC
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