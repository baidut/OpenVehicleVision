classdef RangeSlider < UiModel
    % http://undocumentedmatlab.com/blog/sliders-in-matlab-gui
    %%
    % Example
    %
    %{
	I = imread('circuit.tif');
	range = RangeSlider([0 1]);
	sigma = Slider([0 10]);
	
	sobel = ImCtrl(@edge, I, 'canny', range, sigma);
	Fig.subimshow(I, sobel);
    %}
    %  Project website: https://github.com/baidut/openvehiclevision
    %  Copyright 2016 Zhenqiang Ying [yingzhenqiang-at-gmail.com].
    %
    %%
    % See also
    %
    % Popupmenu, ImCtrl, RangeSlider.
    
    
    
    %% Properties
    properties (GetAccess = public, SetAccess = private)
        span,prop
    end
    
    methods (Access = public)
        function obj = RangeSlider(span, varargin)
            obj.span = span;
            obj.prop = varargin;
        end
        
        function h = plot(obj)
            jRangeSlider = com.jidesoft.swing.RangeSlider(0,100,30,60);  % min,max,low,high
            h = javacomponent(jRangeSlider, obj.Position, gcf);
            % set(jRangeSlider, 'MajorTickSpacing',25, 'MinorTickSpacing',5);
            % set(jRangeSlider, 'MajorTickSpacing',25, 'MinorTickSpacing',5, 'PaintTicks',true, 'PaintLabels',true, ...
            % 'Background',java.awt.Color.white);
            % javahandle_withcallbacks.com.jidesoft.swing.RangeSlider
            set(h,'StateChangedCallback',obj.Callback);
            
            text(obj,inputname(1));
        end
        %   Popmenu.val(handle);
        function value = val(obj,h)
            % note jRangeSlider can only parse int.
            value = double([h.getLowValue h.getHighValue])/100*double(obj.span(2)-obj.span(1));
            % keep data type
            value = cast(value,'like',obj.span);
        end
    end
    
    %%
    methods (Static)
    end
    
end% classdef