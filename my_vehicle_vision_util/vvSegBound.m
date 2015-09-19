function seg = vvSegBound(RawImg)
% RawImg = imread('multi.jpg');
% RawImg = imread('shadowy_road.jpg');

% RawImg = imresize(RawImg, [150, 300]);
[nRow, nCol, ~] = size(RawImg);
  
% shadow's B is max : RGB_max == RGB_B

[RGB_R, RGB_G, RGB_B] = getChannel(RawImg);
RpGmB = RGB_R + RGB_G - 2 * RGB_B;
seg = im2bw(RpGmB, graythresh(RpGmB));
return;

% RGB_min = min(min(RGB_R, RGB_G) , RGB_B);
RGB_max = max(max(RGB_R, RGB_G) , RGB_B);
S2 = double(RGB_max - RGB_B) ./ double(RGB_max + 1); 

%RpGmB = RGB_R + RGB_G - 2 * RGB_B; % train the parameter k 




% H = [ 1,  0,  0,  0, -1;
% 	  1,  0,  0,  0, -1;
% 	  4,  2,  0, -2, -4;
% 	  1,  0,  0,  0, -1;
% 	  1,  0,  0,  0, -1];
  
% H = [ 1 -1; 
%       1 -1];

% GrayImg = RawImg(:,:,1);
% leftBound = imfilter(S2,-H,'replicate');
% RightBound = imfilter(S2,H,'replicate');
% 
% LeftEdge = imfilter(GrayImg,-H,'replicate');
% RightEdge = imfilter(GrayImg,H,'replicate');
% 
% implot(leftBound, RightBound, S2, RawImg);
% figure;
% implot(LeftEdge, RightEdge, S2, RawImg);

% imshowedge(S2);

S2_uint8 = im2uint8(mat2gray(S2));

leftBound = imfilter(S2_uint8,-H,'replicate');
RightBound = imfilter(S2_uint8,H,'replicate');

figure;
% thresholdLocally is not suitable for this case
implot(thresholdLocally(RawImg), S2, RawImg, thresholdLocally(S2_uint8));

%% Edge detection
% 
% % function [edgeSegments, noOfSegments] = ED(image, gradientThreshold, anchorThreshold, smoothingSigma)
% [edgeSegments, noOfSegments] = ED(S2_uint8, 60, 20, 1);
% % 20, 0, 1
% 
% figure;
% implot(S2, RawImg); % zeros(nRow, nCol)
% hold on;
% 
% for i = 1:noOfSegments
% 	for j = 1:size(edgeSegments{i}, 1)
% 		plot(edgeSegments{i}(j, 1), edgeSegments{i}(j, 2), 'y*');
% 	end
% end

%% Line detection
% lineSegmentsRaw = EDLines(RawImg, 1);
% lineSegmentsAfter = EDLines(S2_uint8, 1);
% 
% figure;
% implot(RawImg,S2_uint8);
% hold on;
% selplot(1);plotobj(lineSegmentsRaw);
% selplot(2);plotobj(lineSegmentsAfter);
