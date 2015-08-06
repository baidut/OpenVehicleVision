function Filtered = vvRowFilter(I, method, preprocess, varargin)
%vvRowFilter

% 考虑透视效应，行滤波器的大小线性地调整

if nargin > 2 
	I = preprocess(I, varargin{:}); % 如果有预处理步骤，则先进行预处理
end

I = im2gray(I); % 确保图像为灰度图
[numRow, numColumn] = size(I); % 注意：如果I不是灰度图像会出错

method = upper(method);

switch method
case 'DLD'
	I = double(I); % 含有负数
end

Filtered = I; % 均值滤波去除掉车道标记

for r = 1 : numRow
	% horizon - 5  numColumn - 512
	% s = ceil(5 + r*250/numColumn); % 100过滤不掉，300可以
	s = ceil(5 + r*50/numColumn); % DLD使用
	
	switch method
	% 每一行独立地进行滤波，滤波器的大小跟随透视效应改变
	% 使用一维的滤波方式
	case 'LT' % 均值滤波
		Filtered(r,:) = imfilter(I(r,:), ones(1, s)/s , 'corr', 'replicate');
	case 'MLT' % 中值滤波
		Filtered(r,:) = medfilt2(I(r,:), [1, s]);
	case 'PLT'
	case 'SLT'
		% todo
	case 'SMLT'
		half_s = ceil(s/2);
		Middle = medfilt2(I(r,:), [1, s]);
		Middle = [repmat(Middle(1), [1,half_s]), Middle, repmat(Middle(end), [1,half_s])];
		Filtered(r,:) = Middle(1:end-half_s*2)/2 + Middle(1+half_s*2:end)/2;

	case 'DLD' % -1-1 1 1 1 1 -1 -1
		half_s = ceil(s/2);
		template_DLD = ones(1, s*2);
		template_DLD(1:half_s) = -1;
		template_DLD(half_s*3:s*2) = -1;
		Filtered(r,:) = imfilter(I(r,:), template_DLD, 'corr', 'replicate');

	case '%TEST' % for testing
		Mean = imfilter(I(r,:), ones(1, s)/s , 'corr', 'replicate');
		Middle = medfilt2(I(r,:), [1, s]);
		LT(r,:) = Mean;
		MLT(r,:) = Middle;

		% 扩充s/2
		half_s = ceil(s/2);
		Mean = [repmat(Mean(1), [1,half_s]), Mean, repmat(Mean(end), [1,half_s])];
		Middle = [repmat(Middle(1), [1,half_s]), Middle, repmat(Middle(end), [1,half_s])];

		% SLT(r,:) = (Mean(1:end-half_s*2) + Mean(1+half_s*2:end))/2; % 不转成double会越界
		SLT(r,:) = Mean(1:end-half_s*2)/2 + Mean(1+half_s*2:end)/2; 
		SMLT(r,:) = Middle(1:end-half_s*2)/2 + Middle(1+half_s*2:end)/2;
	end

end

switch upper(method)
case '%TEST'
	figure;
	implot(LT, MLT, SLT, SMLT);
	LT = I - LT;
	MLT = I - MLT;
	SLT = I - SLT;
	SMLT = I - SMLT;
	figure;
	implot(LT, MLT, SLT, SMLT);
end