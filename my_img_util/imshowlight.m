function imshowlight(Raw, method)
%IMSHOWLIGHT extract the light feature of a image.
% USAGE:
%  normal case
% 	IMSHOWLIGHT('pictures/lanemarking/light_sbs_vertical_www.jpg');
% 	IMSHOWLIGHT('pictures/lanemarking/light_highway_sbs.jpg');
% 	IMSHOWLIGHT('pictures/lanemarking/light_highway_sbs.jpg', 'entropythresh');
% 	foreach_file_do('pictures/lanemarking/*light*.picture', @IMSHOWLIGHT, 'graythresh');
%  effect of shadow
% 	IMSHOWLIGHT('pictures/lanemarking/shadow/IMG00576.jpg', 'threshthresh');
% 	IMSHOWLIGHT('pictures/lanemarking/shadow/IMG00576.jpg');
% fixedthresh entropythresh

% _light_*  stronglight 

Raw = im2gray(Raw);

if nargin < 2
	Otsu = im2bw(Raw, graythresh(Raw));
	Iterative = im2bw(Raw, threshthresh(Raw));
	MaxEntropy = im2bw(Raw, entropythresh(Raw));
	% 直方图均衡化后效果更不好
	Histeq = histeq(Raw); AfterHisteq = im2bw(Raw, 240/255);
	figure;
	implot(Raw, Otsu, Iterative, MaxEntropy, AfterHisteq);
else
	BW = im2bw(Raw, eval([method '(Raw)']));
	figure;
	imshow(BW);
end

function thres = fixedthresh(I)
thres = 240/255;

function thres = threshthresh(I)
% 迭代法
thres = 0.5 * ( double(min(I(:))) + double(max(I(:))) );
done = false;
while ~done
	g = I >= thres;
	Tnext = 0.5 * (mean(I(g))+ mean(I(~g))); 
	done = abs(thres - Tnext) < 0.5;
	thres = Tnext;
end
thres = thres/255;

function thres = entropythresh(I)
%一维最大熵法 http://www.ilovematlab.cn/thread-84584-1-1.html
h = imhist(I); 
h1 = h;
len=length(h);     %求出所有的可能灰度
[m,n]=size(I);        %求出图像的大小
h1=(h1+eps)/(m*n);            %算出各灰度点出现的概率 
for i=1:(len-1)
	if h(i)~=0
	P1=sum(h1(1:i));
	P2=sum(h1((i+1):len));
	else continue;
	end
	H1(i)=-(sum(P1.*log(P1)));
	H2(i)=-(sum(P2.*log(P2)));
	H(i)=H1(i)+H2(i);
end
m1 = max(H);
thres = find(H == m1);
thres = thres/255;

% 二值化的方法：
% 全局阈值：固定阈值，最佳阈值：迭代法，Otsu最大类间方差法
% 局部阈值：
% Matlab实现一书源代码中的各种方法
% 直方图统计特征
% 最大熵法保留最大信息量，不适合