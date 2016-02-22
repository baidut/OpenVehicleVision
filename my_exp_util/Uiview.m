classdef Uiview<handle

    properties (GetAccess = public, SetAccess = private)
		style
		prop % properties
		h % handle
    end
	properties (GetAccess = public, SetAccess = public)
		
    end
	
	methods (Static)
	end

    methods (Access = public)
        
		function obj = Uiview(style, varargin)
			obj.style = style;
			obj.prop = varargin;
        end
		
		function obj = plot(obj, h)
			obj.h = uicontrol('style', obj.style, obj.prop{:});
			% if Position is not set
			
			f = gcf;
			pos = h.Position .* [f.Position(3:4) 0 0];
			set(obj.h,'position',pos + [0 -15 180 15]);
        end
		
		function obj = setCallback(obj, func)
			set(obj.h,'callback',func);
        end
		
		function value = val(obj)
			value = get(obj.h,'value');
        end
    end% methods
	
end% classdef