function ICASSP2016(filename)

% function from OpenVehiclelVision: getChannel, implot, plotpoint, plotobj

% the main framework, the modules which can be improved are listed as sub function.

	RawImg = imread(filename);

	[nRow, nCol, ~] = size(RawImg);
	featureMap = featureExtraction(RawImg);

	nSplit = floor(nCol/2);
	roadSegL = segment(featureMap(:,1:nSplit,:));
	roadSegR = segment(featureMap(:,nSplit+1:end,:));

	roadBoundPointsL = boundPoints(roadSegL, true);
	roadBoundPointsR = boundPoints(roadSegR, false);

	% implot(roadSegL,roadSegR,roadBoundPointsL,roadBoundPointsR);
	% return;

	roadBoundLineL = fitLine(roadBoundPointsL, [0:89]);
	roadBoundLineR = fitLine(roadBoundPointsR, [-89:0]);
	roadBoundLineR.move([nSplit, 0]); % x - nSplit, y - 0

	endRowPointL = [roadBoundLineL.row(nRow), nRow];
	endRowPointR = [roadBoundLineR.row(nRow), nRow];

	vanishingPoint = roadBoundLineL.cross(roadBoundLineR);
    nHorizon = vanishingPoint(2);
	horizonLine = LineObj([1, nHorizon], [nCol, nHorizon]);

	pointLU = vanishingPoint/2 + endRowPointL/2;
	pointRU = vanishingPoint/2 + endRowPointR/2;

	movingPoints = [pointLU; pointRU; endRowPointL; endRowPointR];
	nOutCol = 80; nOutRow = 60; % size of map where the lane-making points locate in one column.
	fixedPoints = [1, 1; nOutCol,1; 1,nOutRow; nOutCol, nOutRow];
	tform = fitgeotrans(movingPoints, fixedPoints, 'projective');

	GrayImg = rgb2gray(RawImg);
	BirdView_ROI = imwarp(GrayImg, tform, 'OutputView', imref2d([nOutRow, nOutCol]));

	LaneMark = laneMarkFilter(BirdView_ROI);

	ColPixelSum = sum(LaneMark, 1);
	[maxValue index] = max(ColPixelSum);
	ratio = index / nOutCol;

	endRowPointM = [(1-ratio) * roadBoundLineL.row(nRow) + ratio * roadBoundLineR.row(nRow), nRow];
	roadMidLine = LineObj(vanishingPoint, endRowPointM);

	%% plot results.
	roadSeg = [roadSegL, roadSegR];
	roadBoudPoints = [roadBoundPointsL, roadBoundPointsR];
	BirdView = imwarp(RawImg, tform);

	figure, Initalize = implot(RawImg, BirdView, BirdView_ROI); 
	selplot(1); hold on;
	plotpoint(roadBoudPoints, vanishingPoint, endRowPointL, endRowPointR);
	plotobj(horizonLine, roadBoundLineL, roadBoundLineR, roadMidLine);

	selplot(3); hold on;
	plot([1:nOutCol], ColPixelSum);
	maxfig;

	% write results to file.
    imdump(RawImg, featureMap, roadSeg, roadBoudPoints);

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
    % BW_areaopen = bwareaopen(BW_imclose, 200); % 去除车道线
	BW_Filtered = BW_imclose;   
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
			for c = nCol : -1 : 1
				if 1 == Candidate(r, c)
					Boundary(r, c) = 1;
					break;
				end
			end
		end
	else 
		for r = 1 : nRow
			for c = 1 : nCol
				if 1 == Candidate(r, c)
					Boundary(r, c) = 1;
					break;
				end
			end
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
	ROI = GrayImg(:,(end/3):(end*2/3));
	H = [-1, 0, 1, 0, -1;
	     -1, 0, 2, 0, -1;
	     -1, 0, 2, 0, -1;
	     -1, 0, 2, 0, -1;
	     -1, 0, 1, 0, -1];
	RoadFiltered = imfilter(ROI,H,'replicate'); % & mask
	BW = im2bw( RoadFiltered, graythresh(RoadFiltered) );
	BW_areaopen = bwareaopen(BW,18,4);
	laneMark = zeros(size(GrayImg));
	laneMark(:,(end/3):(end*2/3)) = BW_areaopen;

	% imdump(GrayImg, BW, BW_areaopen, laneMark);
end