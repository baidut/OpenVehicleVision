function maxfig(arg1)
%MAXFIG Maximize figure.
%
%   MAXFIG(H) maximizes the window with handle H.
%   MAXFIG, by itself, maximizes the current figure window.
%  
%   MAXFIG('name') maximizes the named window.
%  
%   MAXFIG ALL  maximizes all the open figure windows.
%  

% Copyright 2015 Zhenqiang YING.  [yingzhenqiang-at-gmail.com] 

    if nargin<1
        max_a_fig(gcf);
        return;
    end

    if ischar(arg1) && strcmp(lower(arg1),'all')
        figs = allchild(0);
        for n = 1:length(figs) 
            max_a_fig(figs(n))
        end
    elseif ishandle(arg1)
        max_a_fig(arg1)
    else
        error('maxfig: Unexpected input.');
    end

end

function max_a_fig(fig)
    if verLessThan('matlab', '7.11')
        jframe=getJFrame(fig);jframe.setMaximized(1);
    else
        scrsz = get(0,'ScreenSize');
        set(fig,'Position',scrsz);
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

    narginchk(1,1);
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

end