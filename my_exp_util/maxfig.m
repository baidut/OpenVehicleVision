function maxfig(varargin)
%MAXFIG Maximized figure
% USAGE:
%	MAXFIG;
%	MAXFIG(fig1, fig2);
if nargin == 0
	maxfig(gcf);
else 
	for i = 1: nargin
		fig = varargin{i};
		if verLessThan('matlab', '7.11')
			jframe=getJFrame(fig);jframe.setMaximized(1); 
			% getJFrame 在R2012a适用，R2015a出错，错误信息如下
			% Undefined function 'abs' for input arguments of type 'matlab.ui.Figure'.
		else
			scrsz = get(0,'ScreenSize');
		    set(fig,'Position',scrsz);
		    % see more http://blog.163.com/yinhexiwen@126/blog/static/6404826620122942057214/
		end
	end
end 

function JFrame = getJFrame(hfig)
%GETJFRAME converts MATLAB figure handle to JAVA object,
%which provides methods like setMaximized, setMinimized and setAlwaysOnTop.
% USAGE:
% 	h=figure;
% 	jframe = getJFrame(gcf); % Alternative: jframe = getJFrame(h);   
% 	jframe.setMaximized(1);
% 	jframe.setMinimized(1);
% 	jframe.setAlwaysOnTop(1);

error(nargchk(1,1,nargin));
if ~ishandle(hfig) && ~isequal(get(hfig,'Type'),'figure')
    error('The input argument must be a Figure handle.');
end
mde = com.mathworks.mde.desk.MLDesktop.getInstance;
if isequal(get(hfig,'NumberTitle'),'off') && isempty(get(hfig,'Name'))
    figTag = 'junziyang'; %Name the figure temporarily
    set(hfig,'Name',figTag);
elseif isequal(get(hfig,'NumberTitle'),'on') && isempty(get(hfig,'Name'))
    figTag = ['Figure ',num2str(hfig)];
elseif isequal(get(hfig,'NumberTitle'),'off') && ~isempty(get(hfig,'Name'))
    figTag = get(hfig,'Name');
else
    figTag = ['Figure ',num2str(hfig),': ',get(hfig,'Name')];
end
drawnow %Update figure window
jfig = mde.getClient(figTag); %Get the underlying JAVA object of the figure.
JFrame = jfig.getRootPane.getParent();
if isequal(get(hfig,'Name'),'junziyang')
    set(hfig,'Name',''); %Delete the temporary figure name
end
