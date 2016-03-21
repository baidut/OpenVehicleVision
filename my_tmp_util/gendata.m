%% generate common data for improving precessing speed.

%% Mask
MaybeRoad = imread('%datasets\nicta-RoadImageDatabase\All.png');%gray 0-255
MaybeRoadMask = MaybeRoad>=128;
%imshow(MaybeRoadMask);


%% load image
% nicta
imgFile = '%datasets\nicta-RoadImageDatabase\After-Rain\after_rain00001.tif';

RawImage = RawImg(imgFile);%0289

%% ROI
ROI = RawImage.rectroi({ceil(RawImage.rows/2):RawImage.rows,1:RawImage.cols});
ROIMask = MaybeRoadMask(ceil(RawImage.rows/2):RawImage.rows,1:RawImage.cols);

%% Way1: most frequent pixel value  
% get_road_region = @(x)x(MaybeRoadMask);
% [roadR,roadG,roadB] = RawImage.eachChn(get_road_region);
% MaybeRoadPixels = cat(2, roadR,roadG,roadB);
% %see http://blogs.mathworks.com/steve/2008/01/31/counting-occurrences-of-image-colors/
%% Way2: Bayers
%% Way3: imseggeodesic
% [L,P] = imseggeodesic(RawImage.data,MaybeRoadMask,~MaybeRoadMask); 
% imshow(RawImage.data+imoverlay(RawImage.data,L==1,[255 0 0]));

%% Based on color feature
% segmentation should not influence by light condition
% V component, L component should not be  considered.
% RGB distance will get bad performance.

% define color similarity == distance of hs space

% better hs(HSV) ab(Lab) worse 

HSV = rgb2hsv(ROI); % rgb2lab
H = HSV(:,:,2);
S2 = vvFeature.S2(ROI);
meanH = mean2(H(ROIMask));
meanS2 = mean2(S2(ROIMask));

H = double(H);
S2 = double(S2);

distance = ( (H - meanH).^2*4/5 + ...
             (S2 - meanS2).^2*1/5).^0.5;
% distance = S2 - meanS2;
%thresh_tool(mat2gray(distance));

RoadRegion = distance < 0.05;%mat2gray(distance) < 0.1;
%imshow(RoadRegion);
imshow(ROI+imoverlay(ROI,RoadRegion,[255 0 0]));
% overwrite save