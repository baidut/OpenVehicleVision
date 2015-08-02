function ok = implot(varargin)
%IMPLOT
% USAGE:
%	I = imread('picture1.jpg'); 
%	J = imread('picture2.jpg');
%	implot(I,J);
%	implot(I,I,J,I,I,I,J,I,I);
%	implot('picture1.jpg', 'picture2.jpg');
% 	files = str2files('pictures/*.picture');
% 	implot(files{:}); % 没有title？
% Freatures: 自动布局、支持变量或者文件名，自动将变量名或文件名作为title、矩阵自动转为灰度图
% Todo: 调整Matlab中Subplot间距
% Notice: implot(images{:}) 

r = floor(sqrt(nargin)); % 确保最优
c = ceil(nargin/r); % 确保足够

% h = figure; %是否重建窗口交给用户来选择
% figure; implot(I);
% hold on;

for i = 1: nargin
	subplot(r, c, i);
	
	image = varargin{i};
	
	if ~isstr(image) && ismatrix(image)  % grey
		imshow(image, []); % imshow(mat2gray(image));
	else % color image
		imshow(image);
	end
	
	if isstr(image)
		name = image;
	else 
		%Filtered_Mean 显示为 Filtered_M_e_a_n
		name = inputname(i); % 'Filtered_Mean'
		
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
	end
	title(name);

end

jframe=getJFrame(gcf);jframe.setMaximized(1); 
% getJFrame 在R2012a适用，R2015a出错，错误信息如下
% Undefined function 'abs' for input arguments of type 'matlab.ui.Figure'.