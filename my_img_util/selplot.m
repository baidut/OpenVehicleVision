function h = selplot(name, fig)
%SELPLOT select a subplot for plot dots, lines or whatever.
%
%   Example
%   -------
%   
%
%	   Football = imread('football.jpg');
%      Cameraman = imread('cameraman.tif'); 
%	   implot(Football, Cameraman);
%	   selplot('Football');
%	   imshow('kids.tif');

if nargin < 2
	fig = gcf;
end

nAxes = 0;

for ii = length(fig.Children):-1:1 % 倒序排列的

	h = fig.Children(ii);
	if ~strcmp(h.Type, 'axes')
		continue;
	end

	nAxes = nAxes + 1; % find 1 axes

	if isnumeric(name) && nAxes == name
		fig.CurrentAxes = h; % subplot(h);
		break;
	end

	% 名称有问题，不一定匹配，建议用序号
	if isstr(name) && strcmp(h.Title.String, name) %~isempty( findstr(fig.Children(1).Title.String, name) )
		subplot(h); % 切换到子图
		break; % 如果重名，则仅返回第一次找到的（返回数组？）
	end

end
