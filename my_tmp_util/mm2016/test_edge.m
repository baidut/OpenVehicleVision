%% Contribution 1: Extract the true edge using S2

%% nicta
% imgFile = '%datasets\nicta-RoadImageDatabase\After-Rain\after_rain00001.tif';
%% Roma
% strong shadow
imgFile = '%datasets\roma\BDXD54\IMG00002.jpg';%'%datasets\roma\BDXD54\IMG00146.jpg';
% weak shadow

%imgFile = '%datasets\roma\LRAlargeur26032003\IMG00579.jpg';%'%datasets\roma\BDXD54\IMG00146.jpg';

Raw = RawImg(imgFile);
ROI = Raw.rectroi({ceil(Raw.rows/2):Raw.rows,1:Raw.cols}); % Near Field
S2 = vvFeature.S2(Raw.data);
S = vvFeature.S(Raw.data);

% first do road marking remval, then do S2 feature extraction
%% Deshadow test
% HSV = rgb2hsv(Raw.data);
% HSV(:,:,3) = S2;
% Deshadow = hsv2rgb(HSV);
% Fig.subimshow(S2,Raw,Deshadow);
% imwrite(Deshadow, 'E:\Documents\MATLAB\G-toolbox\saliency\ca\test\deshadow.bmp');

%% False Edge (no matter how to adjust params)
%%  Traditional way 
%vvEdge.test(rgb2gray(Raw.data));% R component/ B component
%%  Canny
%vvEdge.testCanny(rgb2gray(Raw.data));
%%  Sophisticated Methods (use trained model)
% color image edge
% Pdollar = vvEdge.pdollar(Raw.data);
% imshow(Pdollar);
%%ED 
%% deshadow rgb2ii is useless
% alpha = Slider([0 10]);
% II = ImCtrl(@vvFeature.rgb2ii, Raw.data, alpha);
% Fig.subimshow(S2,II);
%% deshadow gfinvim is useless
%% FIle IMP.zip is useless 
%http://www.mathworks.com/matlabcentral/fileexchange/47243-file-imp-zip
% This is the code the find the Invariant image using the following paper 
% http://www.cs.sfu.ca/~mark/ftp/Eccv04/intrinsicfromentropy.pdf
% Intrinsic Images by Entropy Minimization
% Fig.subimshow(Raw.data, iinv(Raw.data));

%% Our way
SF = vvFeature.ii(Raw.data);
Fig.subimshow(SF,S);
return;

% vvEdge.testCanny(S2);
% E_S2 = 
% imshow(E_S2);


% Fig.subimshow(S2==0,S2,S,S==S2)

alpha = Slider([0 1]);
II = ImCtrl(@vvFeature.ii, Raw.data, alpha);

% II = vvFeature.rgb2ii(Raw.data);
Fig.subimshow(S2,II);
return;