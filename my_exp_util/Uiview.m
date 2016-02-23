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
        
        function handle = plot(obj, h, name, n)
            handle = uicontrol('style', obj.style, obj.prop{:});
            % if Position is not set
            % Axes cannot be a parent.
            f = gcf;
            height = 20;
            width = 120;
            pos = h.Position .* [f.Position(3:4) 0 0] + [0 10 0 0];
            set(handle,'position',pos + [60 -height*n width height]);
            
            %add text
            uicontrol('style','text',...
                'position',pos + [0 -height*n 60 height],...
                'string',name);
        end
    end% methods
    methods (Static)
        function setCallback(h, func)
            % if exist obj.h
            set(h,'callback',func);
        end
        function value = getValue(h) % val:No method 'val' with matching signature found for class 'Uiview'.
            switch h.Style
                case 'popupmenu'
                    maps = h.String;
                    value = maps{h.Value};
                otherwise
                    value = h.Value;
            end
        end
    end% methods
    
end% classdef