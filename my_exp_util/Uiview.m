classdef Uiview<handle
    % Uiview is a model which can be shared by many Uictrls.
    properties (GetAccess = public, SetAccess = private)
        style
        prop % properties
        %h % handle
    end
    
    methods (Access = public)
        function obj = Uiview(style, varargin)
            obj.style = style;
            obj.prop = varargin;
        end
        
        function handle = plot(obj, h)
            handle = uicontrol('style', obj.style, obj.prop{:});
            % if Position is not set
            % parent position ratio
            f = gcf;
            pos = h.Position .* [f.Position(3:4) 0 0];
            set(handle,'position',pos + [0 -15 180 15]);
        end
    end% methods
    methods (Static)
        function setCallback(h, func)
            % if exist obj.h
            set(h,'callback',func);
        end
        function value = val(h)
            value = get(h,'value');
        end
    end% methods
    
end% classdef