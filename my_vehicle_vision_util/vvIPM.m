classdef vvIPM
    %VVIPM perform inverse perspective mapping
    %   Project website: https://github.com/baidut/openvehiclevision
    %   Copyright 2016 Zhenqiang Ying.
    
    %% Public properties
    % properties (GetAccess = public, SetAccess = private)
    % end
    
    %% Static methods
    methods (Static)
        % 'FillValues', 0.8*median(srcImg(nRow,:))
        function TopViewImg = proj2topview(srcImg, movingPoints, rectSize, varargin)
            % rectSize [nOutCol/width, nOutRow/height]
            
            %% if params is not given, then do some testing.
            if nargin < 2
                subplot(1,2,1);
                imshow(srcImg);
                [nRows, nCols, ~] = size(srcImg);
                
                % upleft(x,y);upright;
                % downright;downleft;
                % to specify a poly region
                movingPoints = [1,1; nCols,1; ...
                    nCols,nRows; 1,nRows];
                h = impoly(gca, movingPoints);
                %callback_roi_ipm(movingPoints);
                
                setColor(h,'yellow');
                addNewPositionCallback(h,@(p) callback_roi_ipm(p)); % title(mat2str(p,3))
                disp('Load tform.mat to get the saved transform matrix.');
                return;
            end
            
            function callback_roi_ipm(movingPoints)
                
                % title(mat2str(movingPoints,3));return
                
                fixedPoints = [1, 1;  nCols, 1;...
                    nCols, nRows;     1, nRows];
                
                tform = fitgeotrans(movingPoints, fixedPoints, 'projective');
                
                BirdView = imwarp(srcImg, tform, ...
                    'OutputView', imref2d([3*nRows, 3*nCols],[-nCols 2*nCols], [-nRows, 2*nRows]));
                % imwarp(srcImg, tform, 'OutputView', imref2d([nRows, nCols]));
                subplot(1,2,2);
                imshow(BirdView);
                
                impoly(gca,[nCols,nRows; 2*nCols,nRows; ...
                    2*nCols,2*nRows; nCols,2*nRows]);
                
                save tform.mat tform movingPoints;
            end
            
            %% if params is given, then do IPM
            nOutCol = rectSize(1); nOutRow = rectSize(2); % size of rectangle
            fixedPoints = [1, 1; nOutCol,1; nOutCol, nOutRow; 1,nOutRow];
            tform = fitgeotrans(movingPoints, fixedPoints, 'projective');
            TopViewImg = imwarp(srcImg, tform, varargin{:});
            
        end
        %% plots
        %     MovingPointsSelection = figure;imshow(RawImg);impoly(gca, movingPoints);
        %     axis auto;%axis([endRowPointL(1) endRowPointR(1) 1 nRow]);
        %     saveeps(MovingPointsSelection, RoadFace_ROI);
        
        %% plot results.
        % in detail
        
        % test
        % imref2d([nOutRow, nOutCol],[1 4*nOutRow],[1 nOutCol])
        % imref2d(imageSize,xWorldLimits,yWorldLimits)
        
        % dump ground truth
        % GroundTruth = imread('RIMG00021.pgm');
        % GTBirdView = imwarp(GroundTruth, tform);
        
        
        function test_images(images, movingPoints, outSize) % size: [width, height]
            % vvIPM.test_images('K:\Documents\MATLAB\dataset\road_dataset_pku\1\*.jpg',movingPoints, [640 480]);
            Test = vvTest(@process);
            Test.onImages(images); %func = @process;%@imshow;
            
            function process(image)
                %@(f)imshow(vvIPM.proj2topview(f,movingPoints,[nCols nRows], ...
                %   'OutputView', imref2d([3*nRows, 3*nCols],[-nCols 2*nCols], [-nRows, 2*nRows])));
                nRows = outSize(2); nCols = outSize(1);
                I = vvIPM.proj2topview(image, movingPoints,[nCols nRows], ...
                    'OutputView', imref2d([3*nRows, 3*nCols],[-nCols 2*nCols], [-nRows, 2*nRows]));
                imshow(I);
                h = gcf;
                [~,name,~] = fileparts(h.Name);
                imwrite(I,['%Temp/IPM_', name, '.jpg']);
                close(h);
            end
        end
    end% methods
end% classdef