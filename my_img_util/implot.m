function h = implot(varargin)
%IMPLOT Plot images.
%   IMPLOT(I,J,K,...) plots I,J,K,... with automatic layout, 
%   each input can be a string pecifying the image, a matrix or image data.
%   Filename or variable name of each input and the type of image will be titled.
%
%   Example 1
%   ---------
%   Plot the images of given folder. 
%
%	   Football = imread('football.jpg');
%      Cameraman = imread('cameraman.tif'); 
%	   implot(Football, Cameraman);
%	   implot('kids.tif',rgb2gray(Football), im2bw(Cameraman));
%	   maxfig;
% 
%   Example 2
%   ---------
%   Plot the images of given folder. 
%
%      files = str2files('dataset/lane detection/*.picture');
%      implot(files{:});
% 	
%   See also SELPLOT, MAXFIG, STR2FILES.

% Todo: 调整Matlab中Subplot间距
% 调整colormap放在外部处理
% MAX = max(abs(image(:)));
% imshow(image, [-MAX, MAX]);
% map = colormap('jet');
% % size(map) 彩图是256
% map(size(map,1)/2,:) = [0, 0, 0];
% colormap(map);
% colorbar

% 如果当前已有figure，则不会追加显示（会调整布局，丢失原来的图片）
% 如果hold on 则是在当前figure显示， 否则新建figure
% 覆盖显示hold on

h = gcf; % 没有则新建

if length(h.Children) ~= 0 && ~ishold % 已有图片且不覆盖
	h = figure; % 新建窗口
end

r = floor(sqrt(nargin)); % 确保最优
c = ceil(nargin/r); % 确保足够

for i = 1:nargin
	subplot(r, c, i);
	
	image = varargin{i};
	name = '';

	if isstr(image)
		[PATHSTR,name,EXT] = fileparts(image);
		image = imread(image);
    end
	
	if ismatrix(image)  % grey
		if islogical(image)
			imshow(image);
			% name = ['(binary)', name];
		else 
			% imshow(image);% imshow(image, []); % 
			% mat2gray(image)会转为0到1
			imshow(mat2gray(image));
			% name = ['(gray)', name];
		end
	else % color image
		imshow(image);
	end
	%Filtered_Mean 显示为 Filtered_M_e_a_n
	name = [name, inputname(i)]; % 'Filtered_Mean'
	
	% 双下划线转为空格 TEST__IMAGE_GRAY
	name = strrep(name, '__', ' '); 
	
	% 下标语法支持 
	% eg: 
	% RGB_R - title('RGB_R')  
	% IMAGE_GRAY - title('IMAGE_G_R_A_Y')
	S = regexp(name, '_', 'split');
	if length(S) == 2
		s1 = S{1}; % Filtered
		s2 = S{2}; % Mean
		s_ = repmat('_',1,length(s2)); 
		t = [s_; s2];
		s2 = t(:)' ; %_M_e_a_n
		name = [s1, s2];
	end
	title(name);
end