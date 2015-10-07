function  imdump(varargin)
% 在函数执行完后将用作调试的中间图片写入文件，支持保存fig（传入图像句柄）
% 如果不需要输出调试图片则可以在这里return

% mfilename 返回的是最近一次调用的函数名，这里是imdump 所以不行，需要函数调用栈
% 函数调用栈st存储了调用信息，这里st(1)是imdump, st(2)是调用imdump的函数

% 调试用对象，封装调试相关方法，
% 初始化时声明调试输出目录
% 注意imdump前提是有output文件夹

global doimdump;
global dumpPath;

if ~doimdump
	return; % 默认不输出
end

st = dbstack;
if length(st) > 1
	n = 2;
else
	n = 1;
end

funcname = st(n).name;
line = st(n).line;

for i = 1:nargin
	para = varargin{i};
	filename = [inputname(i), ' @', funcname, '-', num2str(line)];
	if 1 == length(para) && ishandle(para)
		print(para, '-djpeg', [dumpPath '/', filename]);
	else 
		% if ismatrix(para)&& length(para) == 2  % grey
			% image = mat2gray(para);
		% % 文件夹浏览器显示时空格可以分行
		% else %if 3 == size(para, 3)
			% image = para;
		% % else
			% % error(['unkown input:', inputname(i)]);
			% % dbstack
		% end
		image = para;
		imwrite(image, [dumpPath '/' filename, '.jpg']);
	end
end

% 注意改写程序后，可能原图片生成对应的行号发生变化