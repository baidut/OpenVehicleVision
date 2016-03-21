clear all;

% weark shadow
folder = 'LRAlargeur13032003';
no = '02210';

%strong shadow
folder = 'BDXD54';
no = '00071';

folder = ['dataset\roma\', folder];
Original = imread([folder, '\IMG', no, '.jpg']);
GroundTruth = imread([folder, '\RIMG', no, '.pgm']);

%灰度直方图 对标记线局部进行灰度直方图统计
% imhist(GroundTruth);
% 255 0
% figure;implot(Original, GroundTruth);return;
% 测试
numRow = size(Original, 1);
numColumn = size(Original, 2);

%扫描某一行，得出该行的灰度特征RGB分开？

% Original = rgb2hsv(Original);

r = 820; %scan
X = 1:numColumn;
R = Original(r,:,1);
G = Original(r,:,2);
B = Original(r,:,3);

MIN = min(R,G);


% CurRow = Original;
% CurRow(r,:,:) = 255; 
% CurRow = repmat(rgb2gray(Original(r,:,:)), [1, 100]);

figure;
subplot(2,2,1);plot(X,R);
subplot(2,2,2);plot(X,G);
subplot(2,2,3);plot(X,B);
subplot(2,2,4);imshow(Original);hold on;plot([1, numColumn],[r, r], 'r-');
return;




for c = 1:numColumn
	if(GroundTruth(r,c) == 255)

	else 
	end
end


horizon = 310; % param.cal
I = vvPreprocess(Original, horizon);
numColumn = size(I, 2);
numRow = size(I, 1);

NearField = I(end*2/3:end, end/5:end*4/5);
implot(I, NearField, NearField>210, I>210);
figure;
imhist(NearField);
return;

% 滤波后反而分辨性下降
% 先进行透视范围平均，标记内部均匀化处理，移动平均处理 如果差值不大，则取平均值
% 滑动平均
% Filtered = I;
% for r = 1:numRow
% 	for c = 1: numColumn-1
% 		if abs(Filtered(r,c) - Filtered(r,c+1)) < 40 % 基本除了边界都能作用到
% 			Filtered(r,c) = Filtered(r,c)/2+ Filtered(r,c+1)/2;
% 		end
% 	end 
% end

% figure;
% implot(I, Filtered);
% return;
% Original = Filtered;

% L, ML, MR, R

% 先看单行

% 当前行不一定存在
inMarking = false;
index = 0;
for r = 1: numRow
	for c = 1: numColumn
		if ~inMarking
			if GroundTruth(r,c) == 255
				% 左边界
				index = index + 1;
				X(index) = r; 
				
				L(index) = Original(r,c-2);
				ML(index) =  Original(r,c+1);
				inMarking = true;
			end 
		else % inMarking 
			if GroundTruth(r,c) == 0
				% 右边界
				R(index) = Original(r,c+2);
				MR(index) =  Original(r,c-1);
				inMarking = false;
			else
				% inMarking
			end
		end 
	end
end  
hold on;
size(X)
size(L)
size(R)
plot(X, L, 'r*');
plot(X, ML, 'bo');
plot(X, ML-L, 'y^');
% plot(X, MR, 'bo');
% plot(X, R, 'r*');

return;

Dx = I(:,1:end-1) - I(:,2:end);
% Dx = [Dx, zeros(numRow-horizon, 1)]; % 补充最后一列

% I(:,1:end-1)>I(:,2:end)+20 导数一定门限

I_double = double(I);
% EdgeR = I_double(:,1:end-1) ./ I_double(:,2:end); % 非零
w = 10;
% EdgeR = I_double(:,1:end-w) ./ I_double(:,1+w:end); % 非零
EdgeR = (I_double(:,1:end-w) - I_double(:,1+w:end)) ./ I_double(:,1+w:end); % 非零
nColEdgeR = size(EdgeR, 2);

width_marking = 50;
for r = 1 : numRow
	s = ceil(5 + r*width_marking/numColumn); % DLD使用
	% for c = s : numColumn - s

	Marking(r,(1+s)/2:nColEdgeR-s/2) = EdgeR(r, 1:end-s) - EdgeR(r, 1+s:end);
	% end 
end 	

implot(EdgeR, Marking);