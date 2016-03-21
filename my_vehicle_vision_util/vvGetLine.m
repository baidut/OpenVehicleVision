function lines = vvGetLine(I, method, getFeature, varargin)
%VVGETLINE get lines from a binary feature map.
% USAGE:
%	VVGETLINE('pictures/lanemarking/light_singlelane.jpg', 'hough', ...
% 				@vvGetFeature, '1d-dld', ...
%               @vvPreprocess);
%	VVGETLINE('pictures/lanemarking/light.jpg', 'hough', ...
% 				@vvGetFeature, 'light', ...
%               @vvPreprocess);


% http://cn.mathworks.com/help/vision/examples.html

% foreach_file_do( 'pictures/lanemarking/*.picture',
	% @getFeature, 'gray'
	% @impreprocess,
% );

if nargin > 2 
	I = getFeature(I, varargin{:}); % 如果有预处理步骤，则先进行预处理
end

% todo：此处I需要为灰度或二值图

% 不能直接检测
% 提取出区域 区域中心还是？
% 腐蚀成一条线，
% 边缘检测有很多方法
BW = edge(I, 'canny');

switch method
case 'hough'		
	%Hough Transform
	[H,theta,rho] = hough(BW);

	% Finding the Hough peaks (number of peaks is set to 10)
	P = houghpeaks(H,2,'threshold',ceil(0.2*max(H(:))));
	x = theta(P(:,2));
	y = rho(P(:,1));

	%Fill the gaps of Edges and set the Minimum length of a line
	lines = houghlines(BW,theta,rho,P,'FillGap',170,'MinLength',50);
	
	% Plotting the relevant lines
	figure;
	Lines = I;
	implot(I, Lines);
	for i = 1:length(lines)
		xy = [lines(i).point1; lines(i).point2];
		hold on;
		plot(xy(:,1),xy(:,2),'LineWidth',5,'Color','red');
	end
	
otherwise
	error('unknown line detection method.');
end

% hough变换演示