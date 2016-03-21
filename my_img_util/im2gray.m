function Gray = im2gray(Raw)
% 添加各种基本的灰度化处理方式，取RGB最大值等

if isstr(Raw)
	Raw = imread(Raw);
end

if size(Raw, 3) == 3 %~ismatrix(Raw) 旧版本不支持ismatrix
	Raw = rgb2gray(Raw);
end

Gray = Raw;