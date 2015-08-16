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

for ii = 1:length(fig.Children) 
	h = fig.Children(ii);
	if strcmp(h.Title.String, name) %~isempty( findstr(fig.Children(1).Title.String, name) )
        % 如果重名，则仅返回第一次找到的（返回数组？）
        subplot(h); % 切换到子图
		break;
	end
end
