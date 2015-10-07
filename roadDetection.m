function h = roadDetection(FILENAME)
% ROADDETECTION display road detection result of the image file
% specified by the string FILENAME. 
% Based on the static road scene image, the algorithm extract two road 
% boundaries and middle lane-marking using straight line model.
%
% This code is the implementation of the approach proposed in the paper 
% "An Illumination-Robust Approach for Feature-Based Road Detection" 
% (Zhenqiang Ying, Ge Li & Guozhen Tan) to appear in IEEE-ISM2015
% (IEEE International Symposium on Multimedia 2015) conference.
%
%   Example
%   -------
%   Test on Roma dataset.
%      roma_BDXD54 = 'F:\Documents\MATLAB\dataset\roma\BDXD54\*.jpg';
%      figs = foreach_file_do(roma_BDXD54, @roadDetection);
%
%   Project website: https://github.com/baidut/openvehiclevision
%   Copyright 2015 Zhenqiang Ying.

	[~,name,~] = fileparts(FILENAME);
    h = figure('NumberTitle', 'off', 'Name', name);
    
    RawImg = imread(FILENAME);

    % Resize image to improve speed.
    ResizedImg = imresize(RawImg, [150, 200]);
    
    imshow(ResizedImg);
    
    % Proposed approach can be divided to 2 steps, road detection and lane
    % marking detection. 
    % rHorizon is the index of row where horizontal line locates.
    % cBoundaryL/R specify the boundary points of rows below horizon line.
    % thetaSet is the set of possible thetas of lane marking line.

    [rHorizon,cBoundaryL,cBoundaryR,thetaSet] = dtRoadBoundary(ResizedImg);
    dtLaneMarking(ResizedImg,rHorizon,cBoundaryL,cBoundaryR,thetaSet);
end

function [rHorizon, cBoundaryL, cBoundaryR, thetaSet] = dtRoadBoundary(RGB) 
%% init params
    [nRow, nCol, nChannel] = size(RGB);
    rSplit = ceil(nRow/3);
    cSplit = ceil(nCol/2);

    thetaMin = -75;
    thetaMax = 75;

    if nChannel ~= 3
        disp('Color image is needed for road boundary detection.');
        return;
    end
%% image preprocessing

    % Region of interest determination - lower 3/4
    ROI = RGB(rSplit:end,:,:);
    nRowRoi = size(ROI, 1);

    % Image gray value conversion - S2 feature extraction
    B = ROI(:,:,3);
    V = max(ROI,[],3);
    S2 = double(V - B) ./ double(V + 1);

    %% Image segmentation

    S2_bw = S2 > 0.25; % bad performance: S2_bw = im2bw(S2, graythresh(S2)); 
    S2_bw_imclose = imclose(S2_bw, strel('square',3));
    S2_bw_areaopen = bwareaopen(S2_bw_imclose, 50); 

    Boundaries = S2_bw_areaopen;

%% Boundary points extraction

    Candidate = zeros(nRowRoi, nCol);
    BoundaryL = zeros(nRowRoi, cSplit);
    BoundaryR = zeros(nRowRoi, nCol - cSplit);

    % bottom-up scan
    for c = 1 : nCol % for each column
        r = find(Boundaries(:,c),1,'last');
        Candidate(r, c) = 1;
    end

    % middle-side scan
    for r = 1 : nRowRoi
        c1 = find(Candidate(r,1:cSplit),1,'last'); 
        c2 = find(Candidate(r,cSplit+1:end),1,'first');
        BoundaryL(r, c1) = 1;
        BoundaryR(r, c2) = 1;
    end

    imdump(S2, S2_bw, S2_bw_imclose, S2_bw_areaopen, ...
        Candidate, BoundaryL, BoundaryR);

%% Road boundary model fitting
    houghL = figure;
    lineL = bwFitLine(BoundaryL, 0:thetaMax);
    houghR = figure;
    lineR = bwFitLine(BoundaryR, thetaMin:0);
    
    imdump(houghL,houghR);
    close(houghL,houghR);

    if isempty(lineL)
       disp('Fail in left boundary line fitting.');
    else
       thetaMax = ceil(lineL.theta - 20);
       lineL.move([0, rSplit]);
       hold on, lineL.plot('LineWidth',3,'Color','yellow');
    end

    if isempty(lineR)
       disp('Fail in right boundary line fitting.');
    else
       thetaMin = floor(lineR.theta + 20);
       lineR.move([cSplit, rSplit]);
       hold on, lineR.plot('LineWidth',3,'Color','green');
    end

    thetaSet = thetaMin:thetaMax;
    
    if ~isempty(lineL) && ~isempty(lineR)
        PointO = lineL.cross(lineR);
        PointL = [lineL.row(nRow), nRow];
        PointR = [lineR.row(nRow), nRow];
        
        rHorizon = max(1,floor(PointO(2)));
        cBoundaryL = lineL.row(rHorizon:nRow);
        cBoundaryR = lineR.row(rHorizon:nRow);
        
        % Plot results
        hold on;
        
        % lines
        lineH = LineObj([1, rHorizon], [nCol, rHorizon]);
        lineH.plot('LineWidth',3,'Color','blue');
        % extend lines
        lineExL = LineObj(PointO, PointL);
        lineExL.plot('LineWidth',1,'Color','yellow');
        lineExR = LineObj(PointO, PointR);
        lineExR.plot('LineWidth',1,'Color','green');
        
        % points
        plot(PointO(1), PointO(2), 'ro', 'markersize', 10);
        plot(PointL(1), PointL(2), 'r*');
        plot(PointR(1), PointR(2), 'r*');
        
        [X, Y] = find(BoundaryL == 1);
        plot(Y, X+rSplit, 'y+');
        [X, Y] = find(BoundaryR == 1);
        plot(Y+cSplit, X+rSplit, 'g+');
    else
        rHorizon = rSplit;
        sz = [nRow - rHorizon + 1, 1];
        cBoundaryL = repmat(10, sz);
        cBoundaryR = repmat(nCol - 10, sz);
        % +/- 10 for avoiding mistaking boudaries as lane markings 
    end

end

function line = bwFitLine(BW, Theta)
% fit line using non-zero pixels in a binary image by Hough Transform

	[H,theta,rho] = hough(BW, 'Theta', Theta);
    
    %% Show Hough Transform Result.
    imshow(H,[],'XData',theta,'YData',rho,'InitialMagnification','fit');
    xlabel('\theta'), ylabel('\rho');
    axis on, axis normal;
    
	P = houghpeaks(H, 1);
    
	lines = houghlines(BW,theta,rho,P, 'MinLength',10, 'FillGap',570);
	
	if length(lines) > 1, lines = lines(1); end

    if isempty(lines), line = []; return; end
    
	line = LineObj(lines.point1, lines.point2);
    
    % Plot peak points
    hold on;
    plot(theta(P(:,2)),rho(P(:,1)),'s','color','white');
end


function dtLaneMarking(Img,rHorizon,cBoundaryL,cBoundaryR,thetaSet)

%%  Region of interest adjustment
    %ROI = Img(rHorizon:end,:,1);
    ROI = Img(rHorizon:end,:,:);
    V_ROI = im2double(max(ROI, [], 3)); % Note!

%%  Lane-marking feature extraction
    [nRow, nCol, ~] = size(ROI);
    I2 = zeros(nRow, nCol);
    I3 = zeros(nRow, nCol);
    
    for r = 1 : nRow
        mw = ceil(5 * r / nRow); % marking width
        for c = ceil(5*mw + max(1,cBoundaryL(r))):1:floor(min(cBoundaryR(r),nCol) - 5*mw)
            I2(r, c) = V_ROI(r, c) ./ (V_ROI(r , c - mw) + V_ROI(r , c + mw));
            I3(r, c) = (V_ROI(r, c) - (V_ROI(r , c - mw)+ V_ROI(r , c + mw))/2) ...
                 ./ abs(V_ROI(r , c - mw) - V_ROI(r , c + mw));
        end
    end

    mask = I2 ~= 0;
    BW_I2 = im2bw(I2, graythresh(I2(mask)));
    BW_I3 = im2bw(I3, graythresh(I3(mask)));
    
    Marking = bwareaopen(BW_I2&BW_I3, 45);

    imdump(ROI, I2, I3, Marking);

%% Lane model fitting
    houghM = figure;
    line = bwFitLine(Marking, thetaSet);
    imdump(houghM);
    close(houghM);
    
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