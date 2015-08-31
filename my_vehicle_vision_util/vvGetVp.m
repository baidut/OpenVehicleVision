function [VP, linesL, linesR] = vvGetVp(im, lastVP)
%VVGETVP locates Vanishing-point from an input road scene image.

% vvGetVp(im);

%% parameter setting
% precision of location: (0,1] smaller to avoid false detecting, bigger to improve accuracy.
precisionVP = 0.4;

[nRow, nCol, ~] = size(im);
if nargin < 2
	lastVP = [floor(nCol/2), floor(nRow/2)];
end

%% line segment detection
% divide image to parts according to the location of VP detected in last frame. 
RoadL = im(lastVP(2):end, 1:lastVP(1));
RoadR = im(lastVP(2):end, lastVP(1)+1:end);

% detect line segments separately.
[lineSegmentsL, noOfSegmentsL]= EDLines(RoadL, 1);
[lineSegmentsR, noOfSegmentsR]= EDLines(RoadR, 1);

% filter lines according to their angle.
lineFilterAngleL = [LineObj([0 0],[0 0])];
lineFilterAngleR = [LineObj([0 0],[0 0])];

for i = 1:noOfSegmentsL
	lineAngle = lineSegmentsL(i).a;
	lineSegmentsL(i).move([lastVP(2)-1, 0]);
	if lineAngle > -75 && lineAngle < -30
		lineFilterAngleL(end+1) = lineSegmentsL(i);
	end
end
for i = 1:noOfSegmentsR
	lineAngle = lineSegmentsR(i).a;
	lineSegmentsR(i).move([lastVP(2)-1, lastVP(1)]);
	if lineAngle > 30 && lineAngle < 75	
		lineFilterAngleR(end+1) = lineSegmentsR(i);
	end
end

% plot candidate line segments.
LinesDetection = implot(im);
plotobj(lineSegmentsL, lineSegmentsR, lineFilterAngleL, lineFilterAngleR);
imdump(LinesDetection);

%% Vote for VP
% initialize parameters.
VoteVP = zeros(ceil(nRow*precisionVP),ceil(nCol*precisionVP));
VoteVP_L = zeros(size(VoteVP));
VoteVP_R = zeros(size(VoteVP));

for i = 1:length(lineFilterAngleL)
	VoteVP_L = VoteVP_L + lineFilterAngleL(i).path([nRow, nCol], size(VoteVP));
end
for i = 1:length(lineFilterAngleR)
	VoteVP_R = VoteVP_R + lineFilterAngleR(i).path([nRow, nCol], size(VoteVP));
end

% plot vote results.
VoteVP = VoteVP_L .* VoteVP_R; 
[maxVoteVP, index] = max(VoteVP(:)); 
VP = [ mod(index,size(VoteVP,1))/precisionVP, ceil(index/size(VoteVP,1)/precisionVP) ];

VpDetection = implot(im, VoteVP_L, VoteVP_R, VoteVP);
hold on; plot(ceil(index/size(VoteVP,1)),mod(index,size(VoteVP,1)),'yo');
selplot('im');
hold on; plot(VP(2), VP(1), 'y+');
imdump(VoteVP_R, VoteVP_L, VoteVP, VpDetection);

%% LaneDetection according to the orientation of lines.
lineFilterPassVpL = [LineObj([0 0],[0 0])];
lineFilterPassVpR = [LineObj([0 0],[0 0])];
for i = 1:length(lineFilterAngleL)
	if lineFilterAngleL(i).distance2point(VP) < 1/precisionVP
		lineFilterPassVpL(end+1) = lineFilterAngleL(i);
	end
end
for i = 1:length(lineFilterAngleR)
	if lineFilterAngleR(i).distance2point(VP) < 1/precisionVP
		lineFilterPassVpR(end+1) = lineFilterAngleR(i);
	end
end

% plot candidate line segments.
LaneDetection = implot(im);
plotobj(lineFilterAngleL, lineFilterAngleR, lineFilterPassVpL, lineFilterPassVpR);
imdump(LaneDetection);
