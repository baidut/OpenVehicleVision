classdef Popupmenu < UiModel
    %%
    % Example
    %
    %{
	I = imread('circuit.tif');
    direction = Popupmenu({'both','horizontal','vertical'});
    Sobel = ImCtrl(@edge, I, 'sobel', 0.1, direction);
    Fig.subimshow(I, Sobel);
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
        menu,prop
    end
    
    methods (Access = public)
        function obj = Popupmenu(menu, varargin)
            obj.menu = menu;
            obj.prop = varargin;
            
        end
        function h = plot(obj)
            h = uicontrol('style', 'popupmenu', obj.prop{:});
            h.String = obj.menu;
            
            h.Position= obj.Position;
            h.Callback= obj.Callback;
            
            text(obj,inputname(1));
        end
    end
    
    %%
    methods (Static)
        %   Popmenu.val(h);
        function value = val(h)
            maps = h.String;
            value = maps{h.Value};
        end
    end
    
end% classdef