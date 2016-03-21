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
                
                load tform.mat
                h3 = impoly(gca,movingPoints);
                setVerticesDraggable(h3, false);
                
                h = impoly(gca, movingPoints);
 
                setColor(h,'yellow');
                addNewPositionCallback(h,@(p) proj(p)); % title(mat2str(p,3))
                disp('Load tform.mat to get the saved transform matrix.');
                
                oCols = ceil(nCols/3);
                oRows = ceil(nRows/3);
                
                fixedPoints = [1, 1;  oCols, 1;...
                    oCols, oRows;     1, oRows];
                
                tform = fitgeotrans(movingPoints, fixedPoints, 'projective');
                proj(movingPoints);
                return;
            end
            
            function proj(movingPoints)
                title(mat2str(movingPoints,3));
                tform = fitgeotrans(movingPoints, fixedPoints, 'projective');
                
                BirdView = imwarp(srcImg, tform, ...
                    'OutputView', imref2d([3*oRows, 3*oCols],[-oCols 2*oCols], [-oRows, 2*oRows]));
                % imwarp(srcImg, tform, 'OutputView', imref2d([nRows, nCols]));
                subplot(1,2,2);
                imshow(BirdView); 
                hold on;
                rectangle('Position',[oCols oRows oCols oRows],...
                    'EdgeColor','b','LineWidth',3);%plot([oCols 2*oCols 2*oCols oCols oCols], [oRows oRows 2*oRows 2*oRows oRows]);
                 %   2*oCols,2*oRows; oCols,2*oRows])
                h2 = impoly(gca,[oCols,oRows; 2*oCols,oRows; ... 
                    2*oCols,2*oRows; oCols,2*oRows]); % maybe imrect is better
                
                addNewPositionCallback(h2,@(p) proj_back(p));
                save tform.mat tform movingPoints;
            end
            
            function proj_back(p)
                title(mat2str(p,3));
                % move to O
                X = p(:,1) - oCols; % Cols
                Y = p(:,2)- oRows; % Rows
                
                [U,V] = transformPointsInverse(tform,X,Y);
                subplot(1,2,1);
                hold on;
                %plot(U,V);% ,'og'
                setPosition(h3, [U,V]);
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
            % vvIPM.test_images('%datasets\pku\1\*.jpg',movingPoints, [640 480]);
            Test = vvTest(@process);
            Test.onImages(images); %func = @process;%@imshow;
            disp('see folder %Temp.');
            
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