function  saveeps(varargin)

% 和imdump重复率很高

% if nargin == 1 && isstr(varargin{1})
%  	print(varargin{1},'-depsc');
% end

for i = 1:nargin
	para = varargin{i};
	filename = ['output/', inputname(i), '.eps'];
	if 1 == length(para) && ishandle(para)
		figure(para); % 设置为当前图像
		print(filename,'-depsc');
		% close(para); % 关闭图像交给外部
	else 
		h = figure; % 新建figure
		imshow(para);
		print(filename,'-depsc');
		close(h);
	end
end