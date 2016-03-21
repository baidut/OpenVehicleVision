function h = foreach_input_do(test, func, varargin)
% USAGE:
	% foreach_input_do([1:1:2], @edge, I, 'sobel', [], 'both')
	% tmp('hello',[],1,[1:2],'')
% varargin{var}
% 参数必须装在元胞里面 
% foreach_input_do({[1:1:2];{'horizontal', 'vertical', 'both'}} ...
				 % @edge, I, 'sobel', [], '');
% {Sobel, Roberts, LoG, Canny, Prewitt} = foreach_input_do({'sobel', 'roberts', 'log', 'canny', 'prewitt'} ,@edge, I, '');
% implot(I, Sobel, Roberts, LoG, Canny, Prewitt);
% foreach_input_do([1:2:8] ,@disp, []); 
% foreach_input_do([1:2:8] ,@disp);
% h 为函数输出

if nargin < 3
	varargin = {[]};
end 

notgiven = cellfun(@isempty, varargin);
[n_param, n_test] = size(test);
if sum(notgiven) ~= n_param
	error('invalid inputs.');
end

if n_param == 1
	h = cell(1, n_test); % 需要初始化
	pos = find(notgiven == 1);
	idx = 1;
	for m = test
		varargin{pos} = char(m); % m为cell 不转为char会出错，无法赋值
		h{idx} = func(varargin{:}); % disp函数无返回值
		idx = idx + 1;
		% subplot(r, c, i); 此处不提供绘图功能
	end
	%implot(h{:}); %没有title
% n_param == 2 & n_test == 1 % cell
end