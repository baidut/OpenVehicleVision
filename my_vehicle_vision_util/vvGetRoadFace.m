function RoadRegion = vvGetRoadFace(image)
%VVGETROADFACE extract the road face by the saturate
% USAGE:
% vvGetLine('pictures/road/wide_unstructured.jpg', 'hough', ...
%               @VVGETROADFACE);

% 不处理分辨率
% 处理分辨率，恢复高分辨率时会出现锯齿现象。直接提取边界，根据边界细化

NUMROWS = 50;
NUMCOLS = 50;
doresize = 0;

% foreach_file_do('dataset\roma\LRAlargeur26032003\', 'jpg', @main);
% 'dataset\roma\LRAlargeur26032003\IMG00579.jpg'
% 阴影问题 IMG00946 'dataset\roma\LRAlargeur26032003\IMG01542.jpg'

% 先调整尺寸，便于处理，选择合适的分辨率
if isstr(image)
	image = imread(image);
end 

[height, width, nchannel] = size(image);

if nchannel ~= 3
	error('input must be a colour image.');
end

% 
if doresize
	image = imresize(image, [NUMROWS NUMCOLS]);
else
	NUMROWS = height;
	NUMCOLS = width;
end

HSV = rgb2hsv(image);
HSV_S = HSV(:, :, 2);

% LAB = applycform(Resized, makecform('srgb2lab'));
% LAB_A = double(LAB(:,:,2));

% 灰度膨胀还是二值膨胀？ 本质是分割成几部分
% se = strel('ball',3,3);%se = strel('ball',5,5);
% Gray__dilate = imdilate(Saturate,se);

% implot(Raw, Resized, Saturate, Gray__dilate);
% return;
% Gray = LAB_A/2.0 + HSV_S/2;

% se = strel('disk',5);
% Gray = imopen(HSV_S, se); % 后续再改进 开运算效果更差
Gray = HSV_S;

threshold = graythresh(Gray); % Otsu方法效果最好 % 均衡化效果差 Saturate = histeq(Saturate);
% threshold = 0.244; %graythresh(Saturate);%0.12; % 越小，剩下的越少
Binary = ~im2bw(Gray, threshold); %注意取反 提取出路面区域

%  %[1;1;1]; %线型结构元素 
% 问题1： 和天空区域连成一片
% 问题2： 大片阴影还是有干扰
RoadRegion = bwareaopen(Binary, ceil(NUMROWS*NUMCOLS/3)); % 或者求最大联通也行

if doresize
	RoadRegion = imresize(RoadRegion, [height width]);
end 

% if debug % global
figure;
implot(image, Gray, Binary, RoadRegion);

return;


% 计算地平线
% 需要先截掉上部分
% 通过腐蚀封闭 防止天空

% 先腐蚀膨胀一下，去除杂点 也可以在前面灰度膨胀

% 对于结构化道路，道路部分可能被车道线拆分开，所以这种方法会跪掉 除非使劲膨胀 把车道线也淹没
% 找出最大的连通分量即为路面区域。 或采用膨胀腐蚀算法消去噪点
[L, num] = bwlabel(SaturateMap, 4); % TODO 4连通对比
x=zeros(1,num);
for idx=1:num
   x(idx)=sum(sum(L == idx));
end
[m, idx] = max(x);
Connected = (L == idx);

se=strel('line',20,0); 
Road = imdilate(Connected,se); 
Edge = edge(Road,'sobel', 'vertical');
BW = Edge;

implot(I, Saturate, SaturateMap, Connected, Road, Edge);
%return;
% DLD提取的为内部，而Canny为边界，求点乘就没有了。。。