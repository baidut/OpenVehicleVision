
Raw = RawImg('F:\Documents\pku-road-dataset\1\EMER0009\0379.jpg');%0289

%TODO: below the horizon
ROI = Raw.rectroi({ceil(Raw.rows/2):Raw.rows,1:Raw.cols});

%% Segmentation
% vvSeg.felzen(ROI);
ISeg = vvSeg.felzen(ROI,3);
RoadFace = ISeg.maxarea();

%% Road Bound Edge
RoadBound = RoadFace.bound(8);

% implot(ROI, ISeg, RoadFace, imoverlay(ROI, RoadBound.data, [255, 255, 0]));
% return;
%% line detection
Edge = RoadBound.data;
boundAngleRange = 30:75;

BoundL = vvBoundModel.houghStraightLine(Edge, boundAngleRange); % 0:89
BoundR = vvBoundModel.houghStraightLine(Edge, -boundAngleRange); % -89:0

implot(Raw);
hold on;
plotpoint(Edge);% TODO: remove plotpoint
BoundL.plot('r');
BoundR.plot('g');
%% Edge detection
% remove the edge from trees and grass: smooth or resize or thresh canny
% Thumbnails = imresize(ROI, [60 160]); % [240 640] [60 160]
Edge1 = edge(ROI(:,:,2),'canny', [0.060000,0.240000],15);% 5.808820
Edge2 = edge(ROI(:,:,2),'canny', [0.060000,0.240000],5);
% diskEnt = strel('disk',4); % radius of 4 
diskEnt = strel('disk',2);
% joinedIm = imclose(Edge1,diskEnt); 
% se4 = strel('ball',15,5);
joinedIm = imdilate(Edge1,diskEnt); 
%- See more at: http://compgroups.net/comp.soft-sys.matlab/how-do-you-thicken-the-edge-in-a-logical/398712#sthash.XD6C2ACE.dpuf

Edge = joinedIm & Edge2;
% implot(Edge1,Edge2,joinedIm,Edge);




%% Road Face Extraction is needed

% get the edge both in downsample image and raw image hsv image, high and
% low sigma, thresh

% vvEdge.testCanny(I(:,:,2)) % sigma 越高，树木的边缘越少
% sigma 5-10

% LongEdge = bwareaopen(Edge, 30, 8);
% implot(Edge,LongEdge);

% lineSegments = EDLines(ROI, 1.5);
% figure;
% imshow(ROI);
% hold on;
% plotobj(lineSegments);




%EdgeImg -> lines




% thresh = Uiview('slider','min',0,'max',50,'value',uint8(10));
% LongEdgeCtrl = Uictrl(@bwareaopen, Edge, thresh, 4);
% Ui.subplot(Edge, LongEdgeCtrl);
% filter by length

% TODO: int value, some dicrete value, conn

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test EDline
% plotobj(EDLines(I, 1));
%
% I = imread('F:\Documents\pku-road-dataset\1\EMER0009\0289.jpg');
% lineSegments = EDLines(I, 1);
% 
% imshow(I);
% hold on;
% plotobj(lineSegments);
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



Brighter = vvEnhance.brighter(Raw);
implot(Raw,Brighter);
return;

Seg_ROI = vvThresh.otsu(ROI);  % ROI(:,:,2)
implot(Raw, Seg_ROI);return;

E_gray = edge(rgb2gray(I),'canny');
E_g = edge(I(:,:,2),'canny');
S2 = vvFeature.S2(I);
imshow(S2);return;
implot(vvFeature.S(I),S2);return;
E_s2 = edge(vvFeature.S2(I),'canny');
implot(I,E_gray,E_g,E_s2);


% range = Uiview('jrangeslider');
% sigma = Uiview('slider','min',0,'max',10,'value',0.1);

% sobel = Uictrl(@edge, I, 'canny', range, sigma);
% Ui.subplot(I, sobel);

% classdef dualLaneDetector
    % properties
		% RawImg
    % end
	
	% methods
	
		% function obj = dualLaneDetector(imgfile)
			% obj.RawImg = imread(imgfile);
		% end
		% function edge(obj)
			
        % end
	% end
% end