function road_detection_via_ii(imgFile, ii_b)
rawImg = imread(imgFile);
[nRow, nCol, ~] = size(rawImg);
% 1000 10
% 480  4
szFilter = [8 8]; %[8 8]; %ones([1 2])*ceil(nCol/10);
rHorizon = ceil(nRow/2);

roiImg = rawImg(rHorizon:end,:,:);

%% RGB --> II
G = roiImg(:,:,2);
B = roiImg(:,:,3);
% im2double 0~1
iiImg =  2 - (im2double(G+ii_b))./(im2double(B)+eps);
% iiImg(iiImg<0)=0;

% roiImg = im2double(roiImg);
% G = roiImg(:,:,2);
% B = roiImg(:,:,3);
% % im2double 0~1
% iiImg =  2 - (G+ii_b)./(B+eps);

smoothImg = wiener2(iiImg, szFilter);

%%
bw = im2bw(smoothImg, graythresh(smoothImg));
bwSmooth = medfilt2(bw, [5 5]); % first use wiener2 then use medfilt2
bwEroded =  imopen(bwSmooth, strel('disk',8,8)); %imerode(bwSmooth, strel('disk',4,4));

%% max area
maxConnected = false(size(bw));
CC = bwconncomp(bwEroded); % support BwImg

numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
maxConnected(CC.PixelIdxList{idx}) = 1;

roadFace = imfill(maxConnected,'holes');

roadFace = [zeros([rHorizon-1 nCol]); roadFace];
% imshow(roadFace)
% return;
[name, ext] = filename(imgFile);
imwrite(roadFace, [name '_road.' ext]);

% Fig.subimshow(rawImg, iiImg, smoothImg, bw, bwEroded, roadFace);
end

function [name, ext] = filename(file)
pos = find(file=='.',1,'last');
name = file(1:pos-1);
ext = file(pos+1:end);
end