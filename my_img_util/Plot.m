classdef Plot

% TODO: 标注多个对象，颜色不同，并且添加title为变量名称
% 需要先初始化画图位置，默认为gca
% draw = Plot();
% draw.points(O,P,Q) 
% draw.lines(l1,l2)

    %% Public properties
    properties (GetAccess = public, SetAccess = private)
    end
 
    %% Public methods
    methods (Access = public)

        function obj = Plot(var)
        end

        function ratio = plotLane(obj)
		end

		function [pointsM, labeled] = drawLine(obj, ratio)
		end

    end% methods
end% classdef

% Matlab存无白边的fig
% print('result.eps','-depsc')
% print -depsc2 filename.eps
% 有白边
% saveas(gca,'meanshape.bmp','bmp');