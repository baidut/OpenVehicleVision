function h = plotobj(varargin)
%PLOTOBJ Plot objects which has plot method.
%   PLOTOBJ(I,J,K,...) plots I,J,K,... with automatic color arrangement, 
%   each input can be an obj, or array of objs.
%   variable name of each input will be marked.
%
%   Example
%   ---------
%   Plot the images of given folder. 
%
%       l1 = LineObj([10 100], [20 60]);
%       l2 = LineObj([20 150], [21 55]);
%       l3 = LineObj([100 105], [25 112]);
%       plotobj(l1,l2,l3);
% 	
%   See also IMPLOT.

% plot lines and add legend

h = gcf;
c = jet(nargin); % color
name = cell(1,nargin);
handles = zeros(1,nargin);

for i = 1:nargin
	obj = varargin{i};
	name{i} = inputname(i);
	if length(obj)> 1
		for ii = 1:length(obj)
			tmp = obj(ii).plot('color', c(i,:)); % plotobj(obj); % recursive
		end
		handles(i) = tmp;
	elseif isobject(obj)
		handles(i) = obj.plot('color', c(i,:));
	else
		error('unexpected inputs.');
	end
end

legend(handles, name{:}); % 如果生成论文的图片，则可以再关闭标注或覆盖标注