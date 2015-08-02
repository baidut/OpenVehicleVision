function out2fifo(file, func, varargin)
global fifo
	fifo = {fifo{:}, func(file, varargin{:})};
	
% 输出结果到文件中
% out2fifo 将结果输出到缓存中

% foreach_file_do('*.jpg', @out2file, @mygray, 'graythresh'); % 按照变量名和输入文件名进行命名
% % list files
% files = str2files('pictures/lanemarking/*grass*.picture');
% % plot images
% implot(files{:});