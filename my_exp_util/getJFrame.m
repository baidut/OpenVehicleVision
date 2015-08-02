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
