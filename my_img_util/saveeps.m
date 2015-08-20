function  saveeps(varargin)

% 和imdump重复率很高

for i = 1:nargin
	para = varargin{i};
	
	filename = ['output/', inputname(i), '.eps'];
	close all;
	h = figure;
	imshow(para);
	print(filename,'-depsc');
	close(h);
end