%% 
global e;
vvShadowFree.demo();
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KITTI Road Dataset
% imgFile = '%datasets\KITTI\data_road\testing\um_000087.png';
%imgFile = '%datasets\KITTI\data_road\training\image_2\um_000008.png';
% uu_000083
% um_000008
%imgFile = '%datasets\KITTI\data_road\testing\image_2\uu_000091.png';
% um_000046 um_000044 wont show strong shadow on the road
% um_000051 wont show strong shadow on the ground
% um_000066 only show shadow of one side?
% um_000015 uu_000091

%% ROMA 
% imgFile = '%datasets\roma\BDXD54\IMG00146.jpg';

%% nicta
imgFile = '%datasets\nicta-RoadImageDatabase\After-Rain\after_rain00001.tif';

%%
Raw = RawImg(imgFile);
ROI = Raw.rectroi({ceil(Raw.rows/2):Raw.rows,1:Raw.cols});
S2 = vvFeature.Slog(Raw.data);

% first do road marking remval, then do S2 feature extraction
HSV = rgb2hsv(Raw.data);
HSV(:,:,3) = HSV(:,:,3) + 2*S2;
Deshadow = hsv2rgb(HSV);
Fig.subimshow(Deshadow);return;
% Fig.subimshow(repmat((S2), [1 1 3]), S2);
% return;
% Seg = 

% vvSeg.slic(repmat(S2, [1 1 3])); %slic cannot support gray image

% ISeg = vvThresh.otsu(S2);
% Fig.subimshow(S2,ISeg);
size = ceil(Raw.cols/10),
se = strel('ball',size,size);% adjust size to fit diff scale image.
Dilated = mat2gray(imdilate(S2,se));
Fig.subimshow(Raw, S2); return;

%% Distance transform
D = bwdist(ISeg);
figure;
imshow(D,[],'InitialMagnification','fit')
title('Distance transform of ~bw')

return

%% Using IPM and then imdilate gray image with se = strel('line',11,90);

%% Note: Input image must be specified in integer format (e.g. uint8, int16)
%% FUZZY CMEANS (C=2)Two class segmentation
im=im2int16(S2); % imread('cameraman.tif'); % sample image
nClass = 2;
[L,C,U,LUT,H]=FastFCMeans(im,nClass); % perform segmentation
 
% Visualize the fuzzy membership functions
figure('color','w')
subplot(2,1,1)
I=double(min(im(:)):max(im(:)));
c={'-r' '-g' '-b'};
for i=1:nClass
    plot(I(:),U(:,i),c{i},'LineWidth',2)
    if i==1, hold on; end
    plot(C(i)*ones(1,2),[0 1],'--k')
end
xlabel('Intensity Value','FontSize',30)
ylabel('Class Memberships','FontSize',30)
set(gca,'XLim',[0 260],'FontSize',20)
 
subplot(2,1,2)
plot(I(:),LUT(:),'-k','LineWidth',2)
xlabel('Intensity Value','FontSize',30)
ylabel('Class Assignment','FontSize',30)
set(gca,'XLim',[0 260],'Ylim',[0 3.1],'YTick',1:3,'FontSize',20)

% Visualize the segmentation
figure('color','w')
subplot(1,2,1), imshow(im)
set(get(gca,'Title'),'String','ORIGINAL')
 
Lrgb=zeros([numel(L) 3],'uint8');
for i=1:3
    Lrgb(L(:)==i,i)=255;
end
Lrgb=reshape(Lrgb,[size(im) 3]);

subplot(1,2,2), imshow(Lrgb,[])
set(get(gca,'Title'),'String','FUZZY C-MEANS (C=3)')

% If necessary, you can also unpack the membership functions to produce 
% membership maps
Umap=FM2map(im,U,H);
figure('color','w')
for i=1:nClass
    subplot(1,nClass,i), imshow(Umap(:,:,i))
    ttl=sprintf('Class %d membership map',i);
    set(get(gca,'Title'),'String',ttl)
end