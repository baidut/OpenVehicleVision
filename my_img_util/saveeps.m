function  saveeps(varargin)

% 和imdump重复率很�?

% if nargin == 1 && isstr(varargin{1})
%  	print(varargin{1},'-depsc');
% end

for i = 1:nargin
	para = varargin{i};
	filename = ['F:\Documents\MATLAB\Temp/', inputname(i), '.eps'];
	if 1 == length(para) && ishandle(para)
		figure(para); % 设置为当前图�?
		print(filename,'-depsc');
		% close(para); % 关闭图像交给外部
	else 
		h = figure; % 新建figure
		imshow(para);
		print(filename,'-depsc');
		close(h);
	end
end