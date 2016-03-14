classdef UiModel < handle
    properties (GetAccess = public, SetAccess = public)
        Position,Callback
    end
    
    methods (Static)
        function value = val(h)
            value = h.Value;
        end
        % 		function call(h, func)
        % 			h.Callback = func;
        % 		end
        
    end
    methods (Access = public)
        function h = text(obj,txt)
            h = uicontrol('style','text',...
                'position',obj.Position.*[1 1 0 1] + [-50 0 50 0],...
                'string',txt);
        end
        function register(obj,imctrl)
            % do nothing
        end
    end
end% classdef