classdef Slider < UiModel
%%
% Example
%
%{
	I = imread('circuit.tif');
    thresh = Slider([0,0.2]);
    Sobel = ImCtrl(@edge, I, 'sobel', thresh);
    Fig.subimshow(I, Sobel);
%}
%  Project website: https://github.com/baidut/openvehiclevision
%  Copyright 2016 Zhenqiang Ying [yingzhenqiang-at-gmail.com].
%
%%
% See also
%
% Popupmenu, ImCtrl, RangeSlider.
    
    % handle properties
	properties (GetAccess = public, SetAccess = public)
		Position,Callback
    end
	
	%% Properties
    properties (GetAccess = public, SetAccess = private)
		span,prop
    end
    
    methods (Access = public)
        function obj = Slider(span, varargin)
            obj.span = span;
			obj.prop = varargin;
        end
		function h = plot(obj)
			h = uicontrol('style', 'slider', obj.prop{:}, ...
				'min', obj.span(1), ...
				'max', obj.span(2), ...
				'value', ( obj.span(1) + obj.span(2) )/2 ...
			);
			h.Position= obj.Position;
			h.Callback= obj.Callback;
			
			%add inputname text to the left of uicontrol
            uicontrol('style','text',...
                'position',h.Position.*[1 1 0 1] + [-50 0 50 0],...
                'string',inputname(1));
		end
	end
end% classdef