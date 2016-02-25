classdef vvEdge
%VVEDGE do edge extraction
%
%   Example
%   -------
%
%   Project website: https://github.com/baidut/openvehiclevision
%   Copyright 2016 Zhenqiang Ying.
		
    %% Public properties
    % properties (GetAccess = public, SetAccess = private)
    % end
 
    %% Static methods
    methods (Static)
		function test(I)
			if nargin == 0, I = imread('circuit.tif');
			end
			
			thresh = Uiview('slider','min',0,'max',0.2,'value',0.1);
			direction = Uiview('popupmenu','string', {'both','horizontal','vertical'});
			sigma = Uiview('slider','min',0,'max',0.2,'value',0.1);
			thinning = Uiview('popupmenu','string', {'thinning','nothinning'});
			
			sobel = Uictrl(@edge, I, 'sobel', thresh, direction, thinning);
			prewitt = Uictrl(@edge, I, 'prewitt', thresh, direction, thinning);
			roberts = Uictrl(@edge, I, 'roberts', thresh, thinning);

			Ui.subplot(I, sobel, prewitt, roberts);
			% Ui.subplot(I, roberts); % ,sobel, prewitt
			% Ui.subplot(roberts, I);
        end
		
		function testCanny(I)
			if nargin == 0, I = imread('circuit.tif');
			end
			
			% if THRESH is empty ([]), edge chooses low and high values automatically.
			range = Uiview('jrangeslider');
			sigma = Uiview('slider','min',0,'max',10,'value',0.1);
			
			sobel = Uictrl(@edge, I, 'canny', range, sigma);
			Ui.subplot(I, sobel);
		end
		
    end% methods
end% classdef


% function imshowedge(Raw, method)
% %IMSHOWEDGE extract the edge feature of a image.
% % USAGE:
% %  normal case
% % 	IMSHOWEDGE('pictures/lanemarking/light_sbs_vertical_www.jpg');
% % 	foreach_file_do('pictures/lanemarking/*light*.picture', @IMSHOWEDGE, 'canny');
% %  effect of shadow
% % 	IMSHOWEDGE('pictures/lanemarking/shadow/IMG00576.jpg', 'canny');
% % 	IMSHOWEDGE('pictures/lanemarking/shadow/IMG00576.jpg');

% Raw = im2gray(Raw);

% if nargin < 2 % no specifies the method
	% Sobel = edge(Raw, 'sobel', 0.05);
	% Roberts = edge(Raw, 'roberts', 0.05);
	% Prewitt = edge(Raw, 'prewitt', 0.05);
	% LoG = edge(Raw, 'log', 0.003, 2.25);
	% Canny = edge(Raw, 'canny', [0.04 0.10], 1.5);
	% h = fspecial('gaussian',5); %高斯滤波
	% Zerocross = edge(Raw,'zerocross',[ ],h); %zerocross图像边缘提取

	% figure;
	% implot(Raw, Sobel, Roberts, Prewitt, LoG, Canny, Zerocross);
% else
	% Edge = edge(Raw, lower(method));
	% figure;
	% implot(Raw, Edge);
% end

% % % 默认参数下，Sobel效果最好
% % % 还可以返回阈值T
% % T = [];
% % dir = 'both';
% % Sobel = edge(Raw, 'sobel', T, dir);
% % Roberts = edge(Raw, 'roberts', T, dir);
% % Prewitt = edge(Raw, 'prewitt');
% % % default T and sigma
% % LoG = edge(Raw, 'log');
% % Canny = edge(Raw, 'canny');
% % TODO:
% % 45°边缘的Sobel
% % zerocross
% % 绘制参数渐变的效果图 调整参数？
% % 调节某个参数

% % 参考 数字图像处理的Matlab实现

% % % matlab 边缘提取
% % close all
% % clear all
% % Raw=imread('tig.jpg'); %读取图像
% % Raw1=im2double(Raw); %将彩图序列变成双精度
% % Raw2=rgb2gray(Raw1); %将彩色图变成灰色图
% % [thr, sorh, keepapp]=ddencmp('den','wv',Raw2);
% % Raw3=wdencmp('gbl',Raw2,'sym4',2,thr,sorh,keepapp); %小波除噪
% % Raw4=medfilt2(Raw3,[9 9]); %中值滤波
% % Raw5=imresize(Raw4,0.2,'bicubic'); %图像大小
% % BW1=edge(Raw5,'sobel'); %sobel图像边缘提取
% % BW2=edge(Raw5,'roberts'); %roberts图像边缘提取
% % BW3=edge(Raw5,'prewitt'); %prewitt图像边缘提取
% % BW4=edge(Raw5,'log'); %log图像边缘提取
% % BW5=edge(Raw5,'canny'); %canny图像边缘提取
% % h=fspecial('gaussian',5); %高斯滤波
% % BW6=edge(Raw5,'zerocross',[ ],h); %zerocross图像边缘提取
% % figure;
% % subplot(1,3,1); %图划分为一行三幅图，第一幅图
% % imshow(Raw2); %绘图
% % figure;
% % subplot(1,3,1);
% % imshow(BW1);
% % title('Sobel算子');
% % subplot(1,3,2);
% % imshow(BW2);
% % title('Roberts算子');
% % subplot(1,3,3);
% % imshow(BW3);
% % title('Prewitt算子');
