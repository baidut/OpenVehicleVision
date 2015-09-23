function ICASSP2016(files, isvideo, istracking)

% function from OpenVehiclelVision: getChannel, implot, imdump, plotpoint, plotobj

% the main framework, the modules which can be improved are listed as sub function.

	if ~istracking
		if ~isvideo
			% test files, no tracking
			foreach_file_do(files, @(file) {figure,roadDetection(imread(file))} );
		else
			% test a video, no tracking
			foreach_frame_do(files, @(file) roadDetection(file));
		end
	else % tracking
		if ~isvideo
			% test files, tracking
			ok = 0;
			index = 1;
			for i = index : length(files) 
                filename = files{index};
				RawImg = imread(filename);
                
                h = figure('NumberTitle', 'off');
                h.Name = filename;
                
				if ok
					[ok, trackinfo, learninfo] = roadDetection(RawImg, trackinfo, learninfo);
				else
					[ok, trackinfo, learninfo] = roadDetection(RawImg);
				end
				index = index + 1;
			end
		else
			% to be added
		end
	end
end


function [ok, trackinfo, learninfo] = roadDetection(RawImg, trackinfo, learninfo)
    %% set output fold.
global dumppathstr;
 	dumppathstr = 'F:/Documents/MATLAB/Temp/';
    
	%% road detection
	[nRow, nCol, ~] = size(RawImg);

	if nargin > 1
		% trackinfo is provided
		vanishingPoint = trackinfo.vanishingPoint;
		endRowPointL = trackinfo.endRowPointL;
		endRowPointR = trackinfo.endRowPointR;
		ratioLaneMark = trackinfo.ratioLaneMark;

		if nargin > 2
			% RoadFaceClassifier = learninfo.RoadFaceClassifier;
		end
	else
		vanishingPoint = [nCol/2, nRow/3];
		% endRowPointL = [0, nRow];
		% endRowPointR = [nCol, nRow];
	end

	nColSplit = floor(vanishingPoint(1));
	nRowSplit = floor(vanishingPoint(2));
	nHorizon = floor(vanishingPoint(2));

	if exist('endRowPointL', 'var')
		A = floor(vanishingPoint + endRowPointL)/2 + [0, -nHorizon+1];
		B = floor(vanishingPoint + endRowPointR)/2 + [0, -nHorizon+1];

		MaskRoadFace = false(nRow-nHorizon+1, nCol);
		MaskRoadFace(A(2):end, A(1):B(1)) = true;
		MaskRoadBound = false(nRow-nHorizon+1, nCol);
		MaskRoadBound(1:A(2)-1, [1:A(1),B(1):end]) = true; % -1 to avoid overlapping

		% imseggeodesic RGB image
		[Label, ~] = imseggeodesic(RawImg(nHorizon:end,:,:),MaskRoadFace,MaskRoadBound);
		RoadBound = (Label == 2); % label 1 - RoadFace, 2 - RoadBound
		roadSegL = RoadBound(:, 1:nColSplit);
		roadSegR = RoadBound(:, nColSplit+1:end);

	else

		featureMap = featureExtractionByRpGm2B(RawImg); % featureExtractionByRpGm2B
		roadSegL = segmentByOtsu(featureMap(nRowSplit:end, 1:nColSplit,:));
		roadSegR = segmentByOtsu(featureMap(nRowSplit:end, nColSplit+1:end,:));

% 		roadSegL = isBound(RawImg(nRowSplit:end, 1:nColSplit,:));
% 		roadSegR = isBound(RawImg(nRowSplit:end, nColSplit+1:end,:));
    end

	roadBoundPointsL = boundPoints(roadSegL, true);
	roadBoundPointsR = boundPoints(roadSegR, false);
      
    %% dump results of stage 1.
%     roadBoundPointsCandidate = zeros(nRow, nCol);
%     roadBoundPointsCandidate(nRowSplit:end,:) = [roadBoundPointsCandidateL, roadBoundPointsCandidateR];
    
	roadBoundPoints = zeros(nRow, nCol);
    roadBoundPoints(nRowSplit:end,:) = [roadBoundPointsL, roadBoundPointsR];
    
    roadSeg = [roadSegL, roadSegR];
    implot(RawImg, featureMap, roadSeg);
    selplot(1); hold on;
%     [X, Y] = find(roadBoundPointsCandidate == 1);
%     plot(Y, X,'y*');
    [X, Y] = find(roadBoundPoints == 1);
    plot(Y, X,'r*');
    imdump(featureMap, roadBoundPoints);
    
    roadBoundAngleLimit = 80;

    if nargin == 1 % no tracking 
        roadBoundLineL = fitStraightLineByHough(roadBoundPoints, 0:roadBoundAngleLimit); % 0:89
        roadBoundLineR = fitStraightLineByHough(roadBoundPoints, -roadBoundAngleLimit:0); % -89:0
    else
        roadBoundLineL = fitStraightLineByHough(roadBoundPointsL, 0:roadBoundAngleLimit); % 0:89
        roadBoundLineR = fitStraightLineByHough(roadBoundPointsR, -roadBoundAngleLimit:0); % -89:0

        roadBoundLineL.move([0, nRowSplit]);
        roadBoundLineR.move([nColSplit, nRowSplit]);
    end
    
	endRowPointL = [roadBoundLineL.row(nRow), nRow];
	endRowPointR = [roadBoundLineR.row(nRow), nRow];

	vanishingPoint = roadBoundLineL.cross(roadBoundLineR);
    nHorizon = floor(vanishingPoint(2));
	horizonLine = LineObj([1, nHorizon], [nCol, nHorizon]);

	ratioNearField = 0.6; % r% of roadface will be considered as near field.
	pointLeftTop = vanishingPoint*ratioNearField + endRowPointL*(1-ratioNearField);
	pointRightTop = vanishingPoint*ratioNearField + endRowPointR*(1-ratioNearField);
	movingPoints = [pointLeftTop; pointRightTop; endRowPointR; endRowPointL];

	nOutCol = 80; nOutRow = 60; % size of map where the lane-making points locate in one column.
	fixedPoints = [1, 1; nOutCol,1; nOutCol, nOutRow; 1,nOutRow];
	tform = fitgeotrans(movingPoints, fixedPoints, 'projective');
	
	GrayImg = RawImg(:,:,1);
	RoadFaceIPM = imwarp(GrayImg, tform, 'OutputView', imref2d([nOutRow, nOutCol]), 'FillValues', 0.8*median(GrayImg(nRow,:)));

    MovingPointsSelection = figure;imshow(RawImg);impoly(gca, movingPoints);
    axis auto;%axis([endRowPointL(1) endRowPointR(1) 1 nRow]);
    saveeps(MovingPointsSelection, RoadFaceIPM);
    
    
	% if track on, then just focus the near field of last detected lane-marking.
	multiLaneMode = true;

	if ~multiLaneMode
		if ~exist('ratioLaneMark', 'var')
			ratioLaneMark = 0.5;
			halfSearchRange = nOutCol/4;
		else
			halfSearchRange = 5;
		end
		leftLimit = floor(ratioLaneMark*nOutCol-halfSearchRange);
		rightLimit = floor(ratioLaneMark*nOutCol+halfSearchRange);
		laneMark = laneMarkFilter(RoadFaceIPM(:,leftLimit:rightLimit));
	else
		laneMark = laneMarkFilter(RoadFaceIPM);
		leftLimit = 0;
	end
	
	ColPixelSum = sum(laneMark, 1);
	[~, index] = max(ColPixelSum);

	ratioLaneMark = (leftLimit + index) / nOutCol;

	endRowPointM = [(1-ratioLaneMark) * roadBoundLineL.row(nRow) + ratioLaneMark * roadBoundLineR.row(nRow), nRow];
	roadMidLine = LineObj(vanishingPoint, endRowPointM);

	%% plot results.
	% in detail
	BirdView = imwarp(RawImg, tform);
    nOutCol = 600; nOutRow = 450; 
    fixedPoints = [1, 1; nOutCol,1; nOutCol, nOutRow; 1,nOutRow];
	tform = fitgeotrans(movingPoints, fixedPoints, 'projective');
    
    AllRoad = imwarp(RawImg, tform, 'OutputView', imref2d([6*nOutRow, nOutCol],[1 nOutCol], [-5*nOutRow, nOutRow]) ); % 'OutputView', imref2d([nOutRow, nOutCol])
    % imref2d([nOutRow, nOutCol],[1 4*nOutRow],[1 nOutCol])
    % imref2d(imageSize,xWorldLimits,yWorldLimits)


	% GroundTruth = imread('RIMG00021.pgm');
	% GTBirdView = imwarp(GroundTruth, tform);
    
    %% plot paper figures.
%     sizeGrid = 50;% choose size of length of one lanemarking. 300
% 
%     %invtform = invert(tform);
%     fixedPoints = movingPoints;
%     movingPoints = [1, 5*nOutRow; size(AllRoad, 2), 5*nOutRow; 1,size(AllRoad, 1); size(AllRoad, 2), size(AllRoad, 1)];
%     
% 	invtform = fitgeotrans(movingPoints, fixedPoints, 'projective');
%     
% %     u = 1:sizeGrid:size(AllRoad, 2);
% %     v = ones(size(u));
% %      = [u, v, 1] * invtform.T ;
% %     [x, y, ~]
%     
%     GridRaw = imwarp(AllRoad, invtform, 'OutputView', imref2d([nRow, nCol]));
    
	implot(RawImg, BirdView, AllRoad);  % , GTBirdView, BirdView_ROI
	selplot(1); hold on;
	plotpoint(roadBoundPoints, vanishingPoint, endRowPointL, endRowPointR);
	plotobj(horizonLine, roadBoundLineL, roadBoundLineR, roadMidLine);

	% selplot(3); hold on;
	% plot([1:nOutCol], ColPixelSum);
	maxfig;

	% write results to file.
 	imdump(RawImg, roadSeg, roadBoundPoints, RoadFaceIPM, laneMark, BirdView, AllRoad); % featureMap 

    % in brief

	% Initalize = implot(RawImg, BirdView_ROI); 
	% selplot(1); hold on;
	% l1 = LineObj(vanishingPoint, endRowPointL);
	% l2 = LineObj(vanishingPoint, endRowPointR);
	% l1.plot('r');
	% l2.plot('g');
	% roadMidLine.plot('b');
	% maxfig;
	% pause(0.5);

	% check if the detection result is ok. 
	% if not, reject the trackinfo and redetect.
	% if redetect failed, use last detection result. 
	ok = true;
	if nargout > 1
		% trackinfo
		trackinfo = struct;
		trackinfo.vanishingPoint = vanishingPoint;
		trackinfo.ratioLaneMark = ratioLaneMark;
		trackinfo.endRowPointL = endRowPointL;
		trackinfo.endRowPointR = endRowPointR;

		if nargout > 2
			learninfo = 'learninfo: not support now';
			% learninfo.RoadFaceClassifier = RoadFaceClassifier;
		end
	end



	% nested function

	function data = computeFeatureVector()
		% resize the data for training
		nRow2 = nRow-nHorizon;
		nFeature = 2;
		data = zeros( nRow2*nCol, nFeature); % 1 index, num of training pixels. % 4 features.
		% r, c, v, s2
		% data(:, 3) = repmat(1:nRow2, 1, nCol);
		% data(:, 4) = repmat((1:nCol)', nRow2, 1);
		f1 = featureMap(nHorizon+1:end,:); % S2 component
		f2 = RawImg(nHorizon+1:end,:,2); % G component
		data = cat(nFeature, f1(:), double(f2(:)));
	end
	% end nested function
end

% independent function

function BW_Filtered = isBound(RawImg)
% check if a pixel is boundary point
    [RGB_R, RGB_G, RGB_B] = getChannel(RawImg);
    RGB_max = max(max(RGB_R, RGB_G) , RGB_B);   
	FeatureMap = double(RGB_max - RGB_B) ./ double(RGB_max + 1);

%     BW = vvCreateMask(RawImg); 
    I = rgb2hsv(RawImg);
    channel1Min = 0.828;
    channel1Max = 0.469;
    % BW = ( (I(:,:,1) >= channel1Min) | (I(:,:,1) <= channel1Max) ) & ...
    BW = (FeatureMap >= 0.1 +graythresh(FeatureMap)) ;

    BW_imclose = imclose(BW, strel('square',3)); %imdilate imclose imopen
    BW_areaopen = bwareaopen(BW_imclose, 100);  % 60 % size should be adaptive 
	BW_Filtered = BW_areaopen;   
    return;

    Seg = segment(FeatureMap);
%% Refine boundary points
% Remove shadows
    Shadow = RGB_B == RGB_max;
    BW = Seg .* ~Shadow;
    imdump(Seg, BW, Shadow);
end

function FeatureMap = featureExtractionByS2(Rgb)
	[RGB_R, RGB_G, RGB_B] = getChannel(Rgb);
	% RGB_min = min(min(RGB_R, RGB_G) , RGB_B);
	RGB_max = max(max(RGB_R, RGB_G) , RGB_B);
	FeatureMap = double(RGB_max - RGB_B) ./ double(RGB_max + 1);
end

function FeatureMap = featureExtractionByRpGm2B(Rgb)
    [RGB_R, RGB_G, RGB_B] = getChannel(Rgb);
    FeatureMap = RGB_R + RGB_G - 2 * RGB_B;
end

function BW_Filtered = segment(Gray)
    BW = Gray > 2 * mean(Gray(:)); % 2.5 * mean(Gray(end,:));0.15 * max(Gray(:));0.3 0.2
    BW_imclose = imclose(BW, strel('square',3)); %imdilate imclose imopen
    BW_areaopen = bwareaopen(BW_imclose, 60, 4);  % 60
	BW_Filtered = BW_areaopen;   
end

function BW_Filtered = segmentByOtsu(GrayImg)
    BW = im2bw(GrayImg, 0.06 + graythresh(GrayImg));
    %BW_imclose = imclose(BW, strel('square', 5)); %imdilate imclose imopen
    BW_areaopen = bwareaopen(BW, 100, 4); 
	BW_Filtered = BW_areaopen; 
end

function BW = segmentByEdge(GrayImg, isleft)
	H = [ 1,  0,  0,  0, -1;
		  1,  0,  0,  0, -1;
		  4,  2,  0, -2, -4;
		  1,  0,  0,  0, -1;
		  1,  0,  0,  0, -1];

	if ~isleft
		H = -H;
	end
	EdgeFeature = imfilter(GrayImg,H,'replicate');
    BW = im2bw(EdgeFeature,graythresh(EdgeFeature));
    imdump(BW,EdgeFeature);
end

function Boundary = boundPoints(BW, isleft)
	[nRow, nCol] = size(BW);
	Candidate = zeros(nRow, nCol);
	Boundary = zeros(nRow, nCol);

    for c = 1 : nCol % for each column
        r = find(BW(:,c),1,'last');% up-down scan
        Candidate(r, c) = 1;
    end

    if isleft
		for r = 1 : nRow
			c = find(Candidate(r,:),1,'last');      
            Boundary(r, c) = 1;
		end
	else 
		for r = 1 : nRow
			c = find(Candidate(r,:),1,'first');
            Boundary(r, c) = 1;
		end
    end
    
end

function line = fitStraightLineByHough(BW, Theta)
	%Hough Transform
	[H,theta,rho] = hough(BW, 'Theta', Theta);

	% Finding the Hough peaks
	P = houghpeaks(H, 1);
	%x = theta(P(:,2));
	%y = rho(P(:,1));

	%Fill the gaps of Edges and set the Minimum length of a line
	lines = houghlines(BW,theta,rho,P, 'MinLength',10, 'FillGap',570);
	
	if length(lines) > 1
		lines = lines(1);
	end

	if length(lines) ~= 1
		error('Fail in fitLine.');
	end

	% line = LineObj([lines.point1(2), lines.point1(1)], [lines.point2(2), lines.point2(1)]);
	line = LineObj(lines.point1, lines.point2);
end

function line = fitStraightLineByRansac(BW, Theta)
% 直接采用边界点进行Ransac直线�?��效果很差
% �?��支持曲线提取
	[X,Y] = find(BW == 1);
	pts = [X';Y'];
	iterNum = 300;
	thDist = 2;
	thInlrRatio = .1;
	[t,r] = ransac(pts,iterNum,thDist,thInlrRatio);
	k1 = -tan(t);
	b1 = r/cos(t);
	Y = k1*X+b1;
	line = LineObj([X(1), Y(1)], [X(end), Y(end)]);
end

function laneMark = laneMarkFilter(GrayImg)
	H = [-1, 0, 2, 0, -1;
	     -1, 0, 2, 0, -1;
	     -1, 0, 2, 0, -1;
	     -1, 0, 2, 0, -1;
	     -1, 0, 2, 0, -1];
	Filtered = imfilter(GrayImg,H,'replicate'); % & mask
	BW = Filtered > 0.8*max(Filtered(:));
	laneMark = bwareaopen(BW,8,4);
	% imdump(Filtered, BW, BW_areaopen, laneMark);
end