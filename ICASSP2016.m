function ICASSP2016(files)

% function from OpenVehiclelVision: getChannel, implot, imdump, plotpoint, plotobj

% the main framework, the modules which can be improved are listed as sub function.

	ok = 0;
	index = 1;

	for i = index : length(files) 
		if ok
			[ok, trackinfo, learninfo] = roadDetection(files{index}, trackinfo, learninfo);
		else
			[ok, trackinfo, learninfo] = roadDetection(files{index});
		end

		index = index + 1;
	end

end


function [ok, trackinfo, learninfo] = roadDetection(filename, trackinfo, learninfo)

	RawImg = imread(filename);
	[nRow, nCol, ~] = size(RawImg);

	if nargin > 1
		% trackinfo is provided
		lastVanishingPoint = trackinfo.vanishingPoint;
		nColSplit = floor(lastVanishingPoint(1));
		nRowSplit = floor(lastVanishingPoint(2));

		ratioLaneMark = trackinfo.ratioLaneMark;
		if nargin > 2
			% learninfo is provided
		end
	else
		nColSplit = floor(nCol/2);
		nRowSplit = floor(nRow/3);
	end

	featureMap = featureExtraction(RawImg);

	roadSegL = segment(featureMap(nRowSplit:end, 1:nColSplit,:));
	roadSegR = segment(featureMap(nRowSplit:end, nColSplit+1:end,:));

	roadBoundPointsL = boundPoints(roadSegL, true);
	roadBoundPointsR = boundPoints(roadSegR, false);

	% implot(roadSegL,roadSegR,roadBoundPointsL,roadBoundPointsR); return;

	% roadSeg = [roadSegL, roadSegR];
	% Gray = rgb2gray(RawImg);
	% implot(roadSeg, edge(Gray,'canny'), edge(roadSeg,'canny'), edge(featureMap,'canny'));return;

	roadBoundLineL = fitLine(roadBoundPointsL, [0:89]);
	roadBoundLineR = fitLine(roadBoundPointsR, [-89:0]);

	roadBoundLineL.move([0, nRowSplit]);
	roadBoundLineR.move([nColSplit, nRowSplit]);

	endRowPointL = [roadBoundLineL.row(nRow), nRow];
	endRowPointR = [roadBoundLineR.row(nRow), nRow];

	vanishingPoint = roadBoundLineL.cross(roadBoundLineR);
    nHorizon = vanishingPoint(2);
	horizonLine = LineObj([1, nHorizon], [nCol, nHorizon]);

	% road boundary line is extracted, output "ground truth" for learning.

	ratioNearField = 0.6; % r% of roadface will be considered as near field.
	pointLeftUp = vanishingPoint*ratioNearField + endRowPointL*(1-ratioNearField);
	pointRightUp = vanishingPoint*ratioNearField + endRowPointR*(1-ratioNearField);
	movingPoints = [pointLeftUp; pointRightUp; endRowPointL; endRowPointR];

	nOutCol = 80; nOutRow = 60; % size of map where the lane-making points locate in one column.
	fixedPoints = [1, 1; nOutCol,1; 1,nOutRow; nOutCol, nOutRow];
	tform = fitgeotrans(movingPoints, fixedPoints, 'projective');
	
	GrayImg = RawImg(:,:,1);
	RoadFaceIPM = imwarp(GrayImg, tform, 'OutputView', imref2d([nOutRow, nOutCol]));

	% if track on, then just focus the near field of last detected lane-marking.
	if ~exist('ratioLaneMark')
		ratioLaneMark = 0.5;
		halfSearchRange = nOutCol/4;
	else
		halfSearchRange = 5;
	end

	leftLimit = floor(ratioLaneMark*nOutCol-halfSearchRange);
	rightLimit = floor(ratioLaneMark*nOutCol+halfSearchRange);

	laneMark = laneMarkFilter(RoadFaceIPM(:,leftLimit:rightLimit));
	ColPixelSum = sum(laneMark, 1);
	[maxValue index] = max(ColPixelSum);

	ratioLaneMark = (leftLimit + index) / nOutCol;

	endRowPointM = [(1-ratioLaneMark) * roadBoundLineL.row(nRow) + ratioLaneMark * roadBoundLineR.row(nRow), nRow];
	roadMidLine = LineObj(vanishingPoint, endRowPointM);

	%% plot results.

	h = figure('NumberTitle', 'off');
	h.Name = filename;

	% in detail

	roadSeg = [roadSegL, roadSegR];
	roadBoudPoints = zeros(nRow, nCol);
	roadBoudPoints(nRowSplit:end,:) = [roadBoundPointsL, roadBoundPointsR];
	BirdView = imwarp(RawImg, tform);

	Initalize = implot(RawImg, BirdView);  % , BirdView, BirdView_ROI
	selplot(1); hold on;
	plotpoint(roadBoudPoints, vanishingPoint, endRowPointL, endRowPointR);
	plotobj(horizonLine, roadBoundLineL, roadBoundLineR, roadMidLine);

	% selplot(3); hold on;
	% plot([1:nOutCol], ColPixelSum);
	maxfig;

	% write results to file.
 global dumppathstr;
 	dumppathstr = 'F:/Documents/MATLAB/output/';
 	imdump(RawImg, featureMap, roadSeg, roadBoudPoints, RoadFaceIPM, laneMark);

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

		if nargout > 2
			learninfo = 'learninfo: not support now';
		end
	end

	% nested function

	% end nested function
end

% independent function

function FeatureMap = featureExtraction(Rgb)
	[RGB_R, RGB_G, RGB_B] = getChannel(Rgb);
	RGB_min = min(min(RGB_R, RGB_G) , RGB_B);
	RGB_max = max(max(RGB_R, RGB_G) , RGB_B);
	FeatureMap = double(RGB_max - RGB_B) ./ double(RGB_max + 1);
end

function BW_Filtered = segment(Gray)
    BW = Gray > 0.45 * max(Gray(:)); % 2.5 * mean(Gray(:))  0.3 0.2 % 用histeq和graythresh效果不好
    BW_imclose = imclose(BW, strel('square',3)); %imdilate imclose imopen
    BW_areaopen = bwareaopen(BW_imclose, 60); % 去除车道线 固定参数鲁棒性差
	BW_Filtered = BW_areaopen;   
end

function Boundary = boundPoints(BW, isleft)
	[nRow, nCol] = size(BW);
	Candidate = zeros(nRow, nCol);
	Boundary = zeros(nRow, nCol);

	for c = 1 : nCol % for each column
		for r = nRow : -1 : 1 % up-down scan
			if 1 == BW(r, c)
				Candidate(r, c) = 1;
				break;
			end
		end
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

function line = fitLine(BW, Theta)
	%Hough Transform
	[H,theta,rho] = hough(BW, 'Theta', Theta);

	% Finding the Hough peaks
	P = houghpeaks(H, 1);
	x = theta(P(:,2));
	y = rho(P(:,1));

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