classdef Uiview<handle
    % Uiview is a model which can be shared by many Uictrls.
	%TODO: use Uirangeslider
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
		
			% if Position is not set
			% Axes cannot be a parent.
			f = gcf;
			height = 20;
			width = 80;
			pos = h.Position .* [f.Position(3:4) 0 0] + [-140 110 0 0];
			position = pos + [120 -height*n width height];
			
			switch lower(obj.style)
				case {'slider', 'popupmenu'}
					handle = uicontrol('style', obj.style, obj.prop{:});
					set(handle,'position',position);
				case 'jrangeslider'
					% http://undocumentedmatlab.com/blog/sliders-in-matlab-gui
					jRangeSlider = com.jidesoft.swing.RangeSlider(0,100,20,80);  % min,max,low,high
					jRangeSlider = javacomponent(jRangeSlider, [0,0,200,80], gcf);
					% set(jRangeSlider, 'MajorTickSpacing',25, 'MinorTickSpacing',5);
					set(jRangeSlider, 'MajorTickSpacing',25, 'MinorTickSpacing',5, 'PaintTicks',true, 'PaintLabels',true, ...
						'Background',java.awt.Color.white);
					handle = jRangeSlider;
				otherwise
					disp(['unknown style: ' obj.style]);
			end
            
            
            %add text
            uicontrol('style','text',...
                'position',pos + [70 -height*n 50 height],...
                'string',name);
        end
    end% methods
    methods (Static)
        function setCallbackFunc(h, func)
			switch class(h)
				case 'matlab.ui.control.UIControl'
					%uicontrol.
					set(h,'callback',func);
				case 'javahandle_withcallbacks.com.jidesoft.swing.RangeSlider'
					%jRangeSlider
					set(h, 'StateChangedCallback',func);
				otherwise
					disp(['unknown class: ' class(h)]);
			end
        end
        function value = getValue(h) % val:No method 'val' with matching signature found for class 'Uiview'.
			switch class(h)
				case 'matlab.ui.control.UIControl'
					%uicontrol.
					switch h.Style
						case 'popupmenu'
							maps = h.String;
							value = maps{h.Value};
						otherwise
							value = h.Value;
					end
				case 'javahandle_withcallbacks.com.jidesoft.swing.RangeSlider'
					%jRangeSlider
					% note jRangeSlider can only parse int.
					value = double([h.getLowValue h.getHighValue])/100;
				otherwise
					disp(['unknown class: ' class(h)]);
			end
        end
    end% methods
    
end% classdef