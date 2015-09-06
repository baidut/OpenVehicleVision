function ICASSP2016(filename)

% function from OpenVehiclelVision: getChannel, implot, plotpoint, plotobj

	Img = imread(filename);

	[nRow, nCol, ~] = size(Img);
	featureMap = featureExtraction(Img);

	nSplit = floor(nCol/2);
	roadSegL = segment(featureMap(:,1:nSplit,:));
	roadSegR = segment(featureMap(:,nSplit+1:end,:));

	roadBoundPointsL = boundPoints(roadSegL, true);
	roadBoundPointsR = boundPoints(roadSegR, false);

	% implot(roadSegL,roadSegR,roadBoundPointsL,roadBoundPointsR);
	% return;

	roadBoundLineL = fitLine(roadBoundPointsL, [0:89]);
	roadBoundLineR = fitLine(roadBoundPointsR, [-89:0]);
	roadBoundLineR.move([0, nSplit]);

	endRowPointL = roadBoundLineL.row(nRow);
	endRowPointR = roadBoundLineR.row(nRow);

	vanishingPoint = roadBoundLineL.cross(roadBoundLineR);
    nHorizon = vanishingPoint(1);
	horizonLine = LineObj([nHorizon, 1], [nHorizon, nCol]);

	% plot results.
	roadSeg = [roadSegL, roadSegR];
	roadBoudPoints = [roadBoundPointsL, roadBoundPointsR];

	Initalize = implot(Img); hold on;
	plotpoint(roadBoudPoints, vanishingPoint, endRowPointL, endRowPointR);
	plotobj(horizonLine, roadBoundLineL, roadBoundLineR);

	% write results to file.
    imdump(Img, featureMap, roadSeg, roadBoudPoints);

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

	line = LineObj([lines.point1(2), lines.point1(1)], [lines.point2(2), lines.point2(1)]);
end