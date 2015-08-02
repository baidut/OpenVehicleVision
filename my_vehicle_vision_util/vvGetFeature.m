function Binary = vvGetFeature(I, feature, preprocess, varargin)
%GETFEATURE
% USAGE:
% vvGetFeature('pictures/lanemarking/light_singlelane.jpg', 'light');
% 可添加预处理
% foreach_file_do( 'pictures/lanemarking/*.picture', ...
	% @vvGetFeature, 'light', ...
	% @vvPreprocess ...
% );

% http://cn.mathworks.com/help/vision/examples.html
if nargin > 2 
	I = preprocess(I, varargin{:}); % 如果有预处理步骤，则先进行预处理
end 

I = im2gray(I);

switch lower(feature)
case '1d-dld'	
	% noise: shadows
	width = size(I, 2);
	w = ceil(width/35); % width of road % 35太大丢失车道线

	% DLD 1:2:1 
	% w = 2 : [-1 -1 1 1 1 1 -1 -1]/2
	% w 大了噪声大；小了标记线裂开，分成两个边缘
	template_DLD = ones(1, 2*w);
	template_DLD(1:ceil(w/2)) = -1;
	template_DLD(ceil(w*3/2):w*2) = -1;
	
	% 好处是滤波后道路宽度固定 
	DLD = imfilter(I, template_DLD, 'corr', 'replicate'); 
	%figure;imshow(DLD);
	% Binary = DLD;
	Binary = im2bw(DLD, 254/255); % 无需二值化就很明显了
	Binary =  bwareaopen(Binary, ceil(width*7/3) ); 
	
	% 左右不平均问题
case 'tripoint'
	width = size(I, 2);
	w = ceil(width/35); % width of road % 35太大丢失车道线

	for r =  1: size(I, 1) %size(I, 1) : -1 : 1  % 1: height 
		for c = w + 1 : width - w
			% DLD(r, c) = Gray(height - r + 1 , c); % upside down
			
			% 三点式效果很差
			% 道路宽度改为固定值DLD特征公式 Utilizing Instantaneous Driving Direction for Enhancing Lane-Marking Detection
			DLD(r, c) = 2 * I(r, c) - ( I(r, c - w) + I(r, c + w) ) -  abs(I(r, c - w) - I(r, c + w));
		end
	end
	
	% threshold = graythresh(DLD);
	Binary = im2bw(DLD, 100/255); % 无需二值化就很明显了
	
case 'light'
	% threshold = 200;%200;
	% I(I < threshold) = 0;
	% I(I >= threshold) = 1; 
	% Binary = logical(I);
	threshold = graythresh(I);
	Binary = im2bw(I, threshold);
	Binary =  bwareaopen(Binary, 300 );
	
case 'histeq'
	I = histeq(I);
	% threshold = graythresh(I);
	Binary = im2bw(I, 243/255);

case 'edge'
	Binary = edge(I, 'sobel');
		
otherwise
	error('Unknown feature to be extracted.');
end

% Binary =  bwareaopen(Binary, 200); % 滤去孤立点