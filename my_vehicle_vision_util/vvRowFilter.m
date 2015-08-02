function Filtered = vvRowFilter(I, method, preprocess, varargin)
%vvRowFilter

% 考虑透视效应，行滤波器的大小线性地调整

if nargin > 2 
	I = preprocess(I, varargin{:}); % 如果有预处理步骤，则先进行预处理
end

I = im2gray(I); % 确保图像为灰度图
[numRow, numColumn] = size(I); % 注意：如果I不是灰度图像会出错

Filtered = I; % 均值滤波去除掉车道标记

for r = 1 : numRow
	% horizon - 5  numColumn - 512
	s = ceil(5 + r*300/numColumn); % 确保是奇数
	
	switch upper(method)
	% 每一行独立地进行滤波，滤波器的大小跟随透视效应改变
	% 使用一维的滤波方式
	case 'LT' % 均值滤波
		Filtered(r,:) = imfilter(I(r,:), ones(1, s)/s , 'corr', 'replicate');
	case 'MLT' % 中值滤波
		Filtered(r,:) = medfilt2(I(r,:), [1, s]);
	case 'PLT'
	case 'SLT'
	end
end