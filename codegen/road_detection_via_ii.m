function roadFace = road_detection_via_ii(rawImg, ii_method, ii_params, debug)
% please do ROI selection before calling road_detection_via_ii
% 1000 10
% 480  4
szFilter = [8 8]; %[8 8]; %ones([1 2])*ceil(nCol/10);
% otsu is very unstable when there are sky (very high gray value)

%% Illumination Invariant Imaging 
% RGB --> II
iiImg =  ii_method(rawImg, ii_params{:}); %2 - (im2double(G+ii_b))./(im2double(B)+eps);

% roiImg = im2double(roiImg);
% G = roiImg(:,:,2);
% B = roiImg(:,:,3);
% % im2double 0~1
% iiImg =  2 - (G+ii_b)./(B+eps);

%% Filtering
smoothImg = wiener2(iiImg, szFilter);

%% Thresholding 1
% darker = smoothImg<0.8; % upper threshold 0.5;
bw = im2bw(smoothImg, graythresh(smoothImg(smoothImg<0.8))); % smoothImg(1:ceil(end/2),:)

%% Thresholding 2
% T = otsuthresh(imhist(smoothImg(smoothImg<0.8), 16));
% bw = imbinarize(smoothImg,T);

bwSmooth = bw; %medfilt2(bw, [5 5]); % first use wiener2 then use medfilt2
%% 4 4 for small image
bwEroded =  imopen(bwSmooth, strel('disk',4,4)); %imerode(bwSmooth, strel('disk',4,4));
% bwEroded =  ~imclose(~bwSmooth, strel('disk',8,8)); % same result

%% max area
maxConnected = false(size(bw));
CC = bwconncomp(bwEroded); % support BwImg

numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
maxConnected(CC.PixelIdxList{idx}) = 1;

roadFace = imfill(maxConnected,'holes');


%% Debug
if debug
	Fig.subimshow(rawImg, iiImg, smoothImg, bw, bwSmooth, bwEroded, roadFace);
    imwrite(rawImg,'%results/road_area_detection\rawImg.png');
    imwrite(iiImg,'%results/road_area_detection\iiImg.png');
    imwrite(smoothImg,'%results/road_area_detection\smoothImg.png');
    imwrite(bw,'%results/road_area_detection\bw.bmp');
%     imwrite(bwSmooth,'bwSmooth.jpg');
    imwrite(bwEroded,'%results/road_area_detection\bwEroded.bmp');
    imwrite(roadFace,'%results/road_area_detection\roadFace.bmp');
end

% if nargout == 0
%     [name, ext] = filename(imgFile);
%     imwrite(roadFace, [name '_road.' ext]);
% end

end

function [name, ext] = filename(file)
pos = find(file=='.',1,'last');
name = file(1:pos-1);
ext = file(pos+1:end);
end