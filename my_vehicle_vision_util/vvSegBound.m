function BW = vvSegBound(RawImg)
% vvSegBound(imread('shadowy_road.jpg'));
% vvSegBound(imread('many.jpg'));


%% Extract feature map. (the probablity of being a boundary point.

    [RGB_R, RGB_G, RGB_B] = getChannel(RawImg);
    RGB_max = max(max(RGB_R, RGB_G) , RGB_B);
    RGB_min = min(min(RGB_R, RGB_G) , RGB_B);

    
    S2 = double(RGB_max - RGB_B) ./ double(RGB_max + 1);
    RpGm2B = RGB_R + RGB_G - 2 * RGB_B;
    %H2 = double(RGB_G/2 + RGB_R/2) ./ double(RGB_B - RGB_min + 1);
    %H2 = mat2gray(H2);
    
    implot(RawImg, S2, RpGm2B);
    imdump(RpGm2B, S2);
    thresh_tool(RpGm2B);
    thresh_tool(S2);
    return;
    
    
    featureMap = im2uint8(mat2gray(S2));
    
    
%% Segment.

    segment = @(x) im2bw(x, 0.1 + graythresh(x));
    
    Seg = segment(featureMap);
    
    ratio = 0.02;
    thumbnail = imresize(featureMap, ratio); % [32, 40]
    Seg_small = segment(thumbnail);
    
    mask = imresize(Seg_small, size(featureMap));
    
    Seg2 = Seg & mask;
    
    implot(RawImg, featureMap, Seg, mask, Seg2);
    return;

%% Extract bound points.

    

    % Edge based 
    H1 = [ 3,  1,  0;
           1,  0,  -1;
           0,  -1, -3];
    H2 = fliplr(H1);
    
    LeftBound = imfilter(featureMap,H1,'replicate');
	RightBound = imfilter(featureMap,H2,'replicate');
    
    implot(RawImg, featureMap, Seg, LeftBound, RightBound, Seg&LeftBound);
    return;
    
    
% test for segment
	% segment2(RawImg(nHorizon+1:end,:,:),MaskRoadFace, MaskRoadBound);

	% function segment2(img, mask1, mask2)
		% [L,P] = imseggeodesic(img,mask1,mask2);

		% implot(mask1, mask2, img); hold on;
		% visboundaries(mask1,'Color','r');
		% visboundaries(mask2,'Color','b');

		% figure
		% imshow(label2rgb(L),'InitialMagnification', 50)
		% title('Segmented image')

		% figure
		% imshow(P(:,:,1),'InitialMagnification', 50)
		% title('Probability that a pixel belongs to the foreground')
	% end

    %% segmentation 2

	% if RoadFaceClassifier is provided, then reject featureMap and use the classifier.
	% if exist('RoadFaceClassifier', 'var')
	% 	theclass = predict(RoadFaceClassifier, computeFeatureVector());
	% 	featureMap = reshape(theclass, nRow-nHorizon, nCol);
	% end

% vvSegBound(imread('shadowy_road.jpg'));

% shadow's B is max : RGB_max == RGB_B



S3 = double(RGB_R - RGB_B) ./ double(RGB_R + 1);
S4 = double(RGB_G - RGB_B) ./ double(RGB_G + 1);
S5 = S3/2 + S4/2;

% Seg = im2bw(RpGmB, graythresh(RpGmB));
Seg = im2bw(RawImg, graythresh(RawImg));
%% Refine boundary points
% Remove shadows
Shadow = RGB_B == RGB_max;
ShadowMask = imdilate(Shadow, strel('square',3));

BW = Seg .* ~ShadowMask; % imclose the shadow to get better performance

implot(RpGmB, RGB_min == RGB_B , (RGB_min == RGB_B)&(RGB_max == RGB_G));


return;

%RpGmB = RGB_R + RGB_G - 2 * RGB_B; % train the parameter k 




% H = [ 1,  0,  0,  0, -1;
% 	  1,  0,  0,  0, -1;
% 	  4,  2,  0, -2, -4;
% 	  1,  0,  0,  0, -1;
% 	  1,  0,  0,  0, -1];
  
% H = [ 1 -1; 
%       1 -1];

% GrayImg = RawImg(:,:,1);

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
