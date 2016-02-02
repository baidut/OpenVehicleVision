function info = roadDetectionViaBird(RawImg, info)
% ROADDETECTIONVIABIRD display road detection result of the image.
% Based on the static road scene image, the algorithm extract two road
% boundaries and middle lane-marking using straight line model.
%
% This code is the implementation of the approach proposed in the paper
% "Robust Lane Marking Detection using Boundary-Based Inverse Perspective Mapping"
% (Zhenqiang Ying & Ge Li) to appear in IEEE-ICASSP2016
% (IEEE International Conference on Acoustics, Speech and Signal Processing 2016) conference.

% tracking - support
% multilane - not support

[nRow, nCol, ~] = size(RawImg);

%% Configurations
global dodumpFigureInPaper;

boundAngleRange = 35:75;
ratioNearField = 0.6;         % denote how much roadface will be considered as near field.
nOutRow = 60; nOutCol = 80;   % size of the top view image, the bigger, the greater precision.

% load default param if info is not provided
if nargin < 2 || isempty(info)
    info.VP = [nCol/2, nRow/3];        % initial vanishing point
    info.endRowPointL = [1, nRow];
    info.endRowPointR = [nCol, nRow];
    info.ratioLaneMark = 0.5;
    halfSearchRange = nOutCol/4;
else
    halfSearchRange = 5; % only search in near area of last detected lane-marking.
end

%% Preprocessing
% deblock
BlurImg = vvPreproc.deblock(RawImg);

%% Road Bound Points Extraction
% road bound feature extraction
featureMap = vvFeature.S2(BlurImg);
p1 = info.endRowPointL *4/5 + info.endRowPointR *1/5;
p2 = info.endRowPointL *1/5 + info.endRowPointR *4/5;
x = [info.VP(1) p1(1) p2(1)];
y = [info.VP(2) p1(2) p2(2)];
mask = poly2mask(x,y,nRow,nCol);
% imshow(mask)
featureMap(mask) = 0;
% imshow(featureMap);

% split the whole image to 4 parts
nColSplit = floor(info.VP(1)); % the col splitting left and right
nRowSplit = floor(info.VP(2)); % the row splitting up and down

% do thresholding and post-processing
roadSegL = vvPostproc.filterBw(vvThresh.otsu2(featureMap(nRowSplit:end, 1:nColSplit,:)));
roadSegR = vvPostproc.filterBw(vvThresh.otsu2(featureMap(nRowSplit:end, nColSplit+1:end,:)));

roadBoundPointsL = vvBoundModel.boundPoints(roadSegL, true);
roadBoundPointsR = vvBoundModel.boundPoints(roadSegR, false);

% dump process result for debugging
roadBoundPoints = zeros(nRow, nCol);
roadBoundPoints(nRowSplit:end,:) = [roadBoundPointsL, roadBoundPointsR];

roadSeg = zeros(nRow, nCol);
roadSeg(nRowSplit:end, :) = [roadSegL, roadSegR];
imdump(2,featureMap, roadSeg, roadBoundPoints);

%% Road Bound Modeling (using dual straight line model)

% fit straigthline by hough
roadBoundLineL = vvBoundModel.houghStraightLine(roadBoundPointsL, boundAngleRange);
roadBoundLineR = vvBoundModel.houghStraightLine(roadBoundPointsR, -boundAngleRange); % -75:-30

% move lines to xy of raw image
roadBoundLineL.move([0, nRowSplit]);
roadBoundLineR.move([nColSplit, nRowSplit]);

% vanishingpoint is defined as the intersection of two straight lines
% the height of VP is defined as the horizon
info.VP = roadBoundLineL.cross(roadBoundLineR);
nHorizon = floor(info.VP(2));
horizonLine = LineObj([1, nHorizon], [nCol, nHorizon]);

%% BIRD: Boundary-Based IPM for Road Detection

% select four source points
info.endRowPointL = [roadBoundLineL.row(nRow), nRow];
info.endRowPointR = [roadBoundLineR.row(nRow), nRow];
pointLeftTop = info.VP*ratioNearField + info.endRowPointL*(1-ratioNearField);
pointRightTop = info.VP*ratioNearField + info.endRowPointR*(1-ratioNearField);
movingPoints = [pointLeftTop; pointRightTop; info.endRowPointR; info.endRowPointL];

% mapping to a fixed rectangle region
GrayImg = RawImg(:,:,1);
RoadFace_ROI = vvIPM.proj2topview(GrayImg, movingPoints, [nOutCol nOutRow], ...
    'OutputView', imref2d([nOutRow, nOutCol]),'FillValues', 0.8*median(GrayImg(nRow,:)));

%% Lane Marking Detection in Top View Image
% search range
leftLimit = floor(info.ratioLaneMark*nOutCol-halfSearchRange);
rightLimit = floor(info.ratioLaneMark*nOutCol+halfSearchRange);
LaneMark = laneMarkFilter(RoadFace_ROI);
LaneMark(:,[1:leftLimit,rightLimit:end]) = 0;

% Search the column where lane marks in
ColPixelSum = sum(LaneMark, 1);
[~, index] = max(ColPixelSum);

info.ratioLaneMark = index / nOutCol;
endRowPointM = [(1-info.ratioLaneMark) * roadBoundLineL.row(nRow) + info.ratioLaneMark * roadBoundLineR.row(nRow), nRow];
roadMidLine = LineObj(info.VP, endRowPointM);

%% Show Detection Results
l1 = LineObj(info.VP, info.endRowPointL);
l2 = LineObj(info.VP, info.endRowPointR);

if dodumpFigureInPaper
    %% - Dump Figure in Paper
    % note that imshow return a handle of image while implot return a
    % handle of figure.
    figure;
    h1 = implot(RawImg);title('');hold on; % FeatureMap
    l1.plot('r','LineWidth', 8);
    l2.plot('g','LineWidth', 8);
    roadMidLine.plot('b','LineWidth', 8);
    figure; h2 = implot(imoverlay(RoadFace_ROI, LaneMark, [255, 255, 0]));
    saveeps(RawImg, h1, h2);
    figure;
    boundpoints = implot(RawImg);title('');
    hold on;
    plotpoint(roadBoundPoints);
    figure; boundaries = implot(RawImg);title('');
    l1.plot('r','LineWidth', 8);
    l2.plot('g','LineWidth', 8);
    saveeps(featureMap, roadSeg, boundpoints, boundaries);
else
    %% - Dump Results for debugging
    subplot(2,3,1);
    imshow(RawImg);title('Raw image');hold on;
    l1.plot('r');
    l2.plot('g');
    roadMidLine.plot('b');
    
    subplot(2,3,2);
    imshow(RoadFace_ROI);title('Near field roadface');
    
    subplot(2,3,[3 6]);
    nOutRow2 = 450; nOutCol2 = 600;
    RoadFace_All = vvIPM.proj2topview(RawImg, movingPoints, [nOutCol2 nOutRow2], ...
    'OutputView', imref2d([6*nOutRow2, nOutCol2],[1 nOutCol2], [-5*nOutRow2, nOutRow2])); 
    imshow(RoadFace_All);title('Extract roadface');
    
    subplot(2,3,4);
    imshow(imoverlay(featureMap, roadSeg, [255, 255, 0]));
    title('Detection Result');hold on;
    plotpoint(roadBoundPoints, info.VP, info.endRowPointL, info.endRowPointR);
    plotobj(horizonLine, roadBoundLineL, roadBoundLineR, roadMidLine);
    
    subplot(2,3,5);
    imshow(imoverlay(RoadFace_ROI, LaneMark, [255, 255, 0]));
    title('Lane marks');
    hold on; plot(1:nOutCol, ColPixelSum);
    
    %maxfig;
    set(gcf,'outerposition',get(0,'screensize'));
    %set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 30 20]); % [0 0 30 20]
    
    % write results to file.
    %  	imdump(RoadFace_ROI, BirdView, RoadFace_All);
    %     %saveeps;
    %     h = gcf;
    %     [~,name,~] = fileparts(h.Name);
    %     % saveas(h, ['F:\Documents\MATLAB\Temp/', name, '.png']); cannot handle
    %     % maximized figure.
    %     print(name, '-djpeg', '-r300'); % ['F:\Documents\MATLAB\Temp/'
    %     %close(h);
end

%% nested function

end

%% independent function
function laneMark = laneMarkFilter(GrayImg)
H = [-1, 0, 2, 0, -1;
    -1, 0, 2, 0, -1;
    -1, 0, 2, 0, -1;
    -1, 0, 2, 0, -1;
    -1, 0, 2, 0, -1;
    -1, 0, 2, 0, -1;
    -1, 0, 2, 0, -1];
Filtered = imfilter(GrayImg,H,'replicate'); % & mask
BW = Filtered > 0.8*max(Filtered(:));
laneMark = bwareaopen(BW,18,4);
% saveeps(Filtered, BW, laneMark);
end