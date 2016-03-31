function [  ] = ii_based_on_linear_assumption(inputImage)

% ii_based_on_linear_assumption(imread('%datasets\roma\BDXD54\IMG00002.jpg'))

if nargin<1
%     inputImage = imread('%datasets\roma\BDXD54\IMG00002.jpg');
%     inputImage = imread('%datasets\KITTI\data_road\training\image_2\um_000023.png');

%% Figure in paper % uu_000037
% inputImage = imread('%datasets\KITTI\data_road\training\image_2\uu_000046.png');
% umm_000054 uu_000086 uu_000064 uu_000077
inputImage = imread('%datasets\KITTI\data_road\training\image_2\uu_000053.png'); %
%     inputImage = ImCtrl(@imread, FilePick());
end

show_rgb2ii_2d(inputImage);return % get params 
show_rgb2ii_3d(inputImage);

end 

function get_ii3d_param(inputImage)

k1 = Slider([-1 1]);
k2 = Slider([-1 1]);
k3 = Slider([-1 1]);

ii3dR = ImCtrl(@rgb2ii_3d_c, inputImage, k1, k2, k3, 1);
ii3dG = ImCtrl(@rgb2ii_3d_c, inputImage, k1, k2, k3, 2);
ii3dB = ImCtrl(@rgb2ii_3d_c, inputImage, k1, k2, k3, 3);

f = Fig;
f.maximize();
f.subimshow(inputImage, ii3dR, ii3dG, ii3dB);

end

function show_rgb2ii_2d(inputImage)

alpha = Slider([0 255], 'Value', 0.2*255);
ii2dRG = ImCtrl(@rgb2ii_2d, inputImage, [1 2], alpha); % [1 2]
ii2dGB = ImCtrl(@rgb2ii_2d, inputImage, [2 3], alpha);
ii2dRB = ImCtrl(@rgb2ii_2d, inputImage, [1 3], alpha); % [3 1]

f = Fig;
f.maximize();
f.subimshow(inputImage, ii2dRG, ii2dGB, ii2dRB);

end

function show_rgb2ii_3d(inputImage)

alpha = Slider([0 255], 'Value', 0.2*255);
ii3d = ImCtrl(@rgb2ii_3d, inputImage);
ii3d2 = ImCtrl(@rgb2ii_3d2, inputImage);
ii3d3 = ImCtrl(@rgb2ii_3d3, inputImage);

f = Fig;
f.maximize();
f.subimshow(inputImage, ii3d, ii3d2, ii3d3);

end

function ii = rgb2ii_2d(rgb, chns, c)
% since the / we cannot use int type
% log 
    rgb = double(rgb); % im2int16 will do rescaling, so int16 should be used
    
    R1 = rgb(:,:,chns(1));
    R2 = rgb(:,:,chns(2));
    
    ii =  2 - (R1+c)./(R2+1); % +1 to avoid /0
%     max(ii(:))
%     min(ii(:))
    ii(ii<0) = 0;
    ii(ii>1) = 1; % ii double
end

function ii = rgb2ii_3d(rgb)
%% 3d recovery

% inputImage = imread('%datasets\roma\BDXD54\IMG00002.jpg');
% inputImage = imread('%datasets\KITTI\data_road\training\image_2\um_000023.png');
    ii2dRG = rgb2ii_2d(rgb,[1,2],12.4501);
    ii2dGB = rgb2ii_2d(rgb,[2,3],18.7499);
    ii2dRB = rgb2ii_2d(rgb,[1,3],27.9750);
                % R       G       B
    ii = cat(3, ii2dRB, ii2dRG, ii2dGB);
end

function ii = rgb2ii_3d2(rgb)
%% 3d recovery

    ii2dRG = rgb2ii_2d(rgb,[1,2],12.4501);
    ii2dGB = rgb2ii_2d(rgb,[2,3],18.7499);
    ii2dRB = rgb2ii_2d(rgb,[1,3],27.9750);
                % R       G       B
    R = 0.7059*ii2dRG+0.6876*ii2dGB-0.7612*ii2dRB;
    G = 0.8088*ii2dRG-0.2353*ii2dGB;
    B = 0.8529*ii2dRG+0.1176*ii2dGB-0.4212*ii2dRB;
    ii = cat(3, R, G, B);
end

function ii = rgb2ii_3d3(rgb)
%% 3d recovery

    ii2dRG = rgb2ii_2d(rgb,[1,2],4); % 4 12.4501
    ii2dGB = rgb2ii_2d(rgb,[2,3],11.9251); % 11.9251 18.7499
%     ii2dRB = rgb2ii_2d(rgb,[1,3],16.1999); % 16.1999 27.9750
                % R       G       B
    R = rgb2ii_2d(rgb,[1 3],16.1999);%1-ii2dRB;%rgb2ii_2d(rgb,[3,1],27.9750);%0.7059*ii2dRG+0.6876*ii2dGB-0.7612*ii2dRB;
    G = ii2dRG; %0.8088*ii2dRG-0.2353*ii2dGB;
    B = ii2dGB; % 0.8529*ii2dRG+0.1176*ii2dGB-0.4212*ii2dRB;
    ii = cat(3, R, G, B);
end

function ii = rgb2ii_3d_c(rgb, k1, k2, k3, c)
%% 3d recovery

% inputImage = imread('%datasets\roma\BDXD54\IMG00002.jpg');
% inputImage = imread('%datasets\KITTI\data_road\training\image_2\um_000023.png');
    ii2dRG = rgb2ii_2d(rgb,[1,2],12.4501);
    ii2dGB = rgb2ii_2d(rgb,[2,3],18.7499);
    ii2dRB = rgb2ii_2d(rgb,[1,3],27.9750);
                % R       G       B
    ii = k1*ii2dRG + k2*ii2dGB + k3*ii2dRB;
    ii = abs(ii-im2double(rgb(:,:,c)));
%     title(num2str(ii-rgb(:,:,1)));
end