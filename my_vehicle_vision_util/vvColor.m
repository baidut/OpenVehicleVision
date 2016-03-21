% Colorspace Transformations
% http://cn.mathworks.com/matlabcentral/fileexchange/28790-colorspace-transformations

function imshowcolor(RGB, colorspace)
%IMSHOWCOLOR show the color channels of an image. 
% IMSHOWCOLOR(RGB, colorspace) shows the specific colorspace when it is given, 
% otherwise it shows all available channels. 
% colorspace can be 'rgb, gray, hsv, ycbcr, ntsc, lab(not case sensitive)'.
% 
% USAGE:
% IMSHOWCOLOR('dataset\roma\LRAlargeur26032003\IMG00579.jpg');
% IMSHOWCOLOR('dataset\roma\BDXD54\IMG00002.jpg', 'hsv');
% IMSHOWCOLOR('pictures/2.jpg', 'gray');
% IMSHOWCOLOR('pictures/2.jpg', 'RGB');
% IMSHOWCOLOR('pictures/2.jpg', 'YCbCr'); 
% IMSHOWCOLOR('pictures/2.jpg', 'Lab'); 
% foreach_file_do('pictures\shadowS', @IMSHOWCOLOR);
% foreach_file_do('pictures\shadowS', @IMSHOWCOLOR, 'hsv');
% foreach_file_do('dataset\roma\LRAlargeur26032003\*.jpg', @IMSHOWCOLOR, 'hsv');
% foreach_file_do('dataset\roma\LRAlargeur14062002\*.jpg', @IMSHOWCOLOR, 'hsv');
% foreach_file_do('dataset\*.jpg', @IMSHOWCOLOR, 'hsv');

% TEST IMAGE:
% dataset\roma\LRAlargeur26032003\IMG00579.jpg
% 结论�?通过饱和度划分最可靠
% 之后就是采用横轴统计进行区域选择，消失点，地平线的检�?
% TODO：getChannel改为子函数，支持更多颜色空间
% help rgb2[tab]

if isstr(RGB)
	RGB = imread(RGB);
end

if nargin < 2 % no specifies the colorspace

	[RGB_R, 	RGB_G, 		RGB_B	] = getChannel(RGB);
	[HSV_H, 	HSV_S, 		HSV_V	] = getChannel(rgb2hsv(RGB));
	[YCbCr_Y, 	YCbCr_Cb, 	YCbCr_Cr] = getChannel(rgb2ycbcr(RGB));
	[YIQ_Y, 	YIQ_I, 		YIQ_Q	] = getChannel(rgb2ntsc(RGB));
	[LAB_L, 	LAB_A, 		LAB_B	] = getChannel(applycform(RGB,makecform('srgb2lab')));

	figure;
	implot(	RGB, ...
			RGB_R, 		RGB_G, 		RGB_B	 , ...
			HSV_H, 		HSV_S, 		HSV_V	 , ...
			YCbCr_Y, 	YCbCr_Cb, 	YCbCr_Cr , ...
			YIQ_Y, 		YIQ_I, 		YIQ_Q	 , ...
			LAB_L, 		LAB_A, 		LAB_B	  ...
		  );
	return;
end

% 通过eval将字符串作为matlab命令执行
if ~ isstr(colorspace)
	error('colorspace must be a string.');
end 

switch lower(colorspace)
case 'rgb'
	I = RGB;
case 'lab'
	I = applycform(RGB,makecform('srgb2lab'));
otherwise
	convertFunc = ['rgb2' colorspace];
	if exist(convertFunc) == 2
		I = eval([convertFunc '(RGB)']);
	else
		error('invalid colorspace!'); % gray
	end
end

J = [I(:,:)];

% figure;
% imshow(RGB);
figure;
imshow(J);