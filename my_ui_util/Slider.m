classdef Slider < UiModel
    %%
    % Example
    %
    %{
    I = imread('circuit.tif');
    thresh = Slider([0,0.2]);
    Sobel = ImCtrl(@edge, I, 'sobel', thresh);
    imshow(Sobel);
    
    % Fig.subimshow(I, Sobel);
    %}
    %  Project website: https://github.com/baidut/openvehiclevision
    %  Copyright 2016 Zhenqiang Ying [yingzhenqiang-at-gmail.com].
    %
    %%
    % See also
    %
    % Popupmenu, ImCtrl, RangeSlider.
    
    %TODO: check int* support
    
    %% Properties
    properties (GetAccess = public, SetAccess = private)
        span,prop
    end
    
    methods (Access = public)
        function obj = Slider(span, varargin)
            % span [min minorstep majorstep max]
            obj.span = span;
            obj.prop = varargin;
        end
        function h = plot(obj)
            h = uicontrol('style', 'slider', ...
                'min', obj.span(1), ...
                'max', obj.span(2), ...
                'value', mean([obj.span(1),obj.span(2)]), ... 
                obj.prop{:} ... %  rewrite default prop
                ); 
            % Note: 'value', ( obj.span(1) + obj.span(2) )/2 may change value type, 
            % eg. uint8 -> double
            h.Position= obj.Position;
            h.Callback= obj.Callback;
            
            %add inputname text to the left of uicontrol
            text(obj,inputname(1));
        end
        
        function value = val(obj,h)
			value = h.Value;
            value = cast(value, 'like', obj.span);
		end 
    end
end% classdef