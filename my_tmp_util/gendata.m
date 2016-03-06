%% generate common data for improving precessing speed.

%% nicta
imgFile = '%datasets\nicta-RoadImageDatabase\After-Rain\after_rain00001.tif';

%% Mask
MaybeRoad = imread('%datasets\nicta-RoadImageDatabase\All.png');%gray 0-255
MaybeRoadMask = MaybeRoad>=128;
%imshow(MaybeRoadMask);

RawImage = RawImg(imgFile);%0289

%% Way1: most frequent pixel value  
% get_road_region = @(x)x(MaybeRoadMask);
% [roadR,roadG,roadB] = RawImage.eachChn(get_road_region);
% MaybeRoadPixels = cat(2, roadR,roadG,roadB);
% %see http://blogs.mathworks.com/steve/2008/01/31/counting-occurrences-of-image-colors/
%% Way2: Bayers
%% imseggeodesic
% [L,P] = imseggeodesic(RawImage.data,MaybeRoadMask,~MaybeRoadMask); 
% imshow(RawImage.data+imoverlay(RawImage.data,L==1,[255 0 0]));

%% Based on color feature
% define color similarity == distance of hs space
LabImage = rgb2hsv(RawImage.data); % rgb2lab
a = LabImage(:,:,2);
b = LabImage(:,:,1);
color_markers(1) = mean2(a(MaybeRoadMask));
color_markers(2) = mean2(b(MaybeRoadMask));

a = double(a);
b = double(b);

distance = ( (a - color_markers(1)).^2 + ...
             (b - color_markers(2)).^2 ).^0.5;

%thresh_tool(mat2gray(distance));

RoadRegion = distance < 0.07;%mat2gray(distance) < 0.1;
imshow(RoadRegion);
% overwrite save