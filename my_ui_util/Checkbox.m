classdef Checkbox < UiModel
    %%
    % True(Selected) or false
    %
    %  Project website: https://github.com/baidut/openvehiclevision
    %  Copyright 2016 Zhenqiang Ying [yingzhenqiang-at-gmail.com].
    %
    %%
    % See also
    %
    % Popupmenu, ImCtrl, RangeSlider.
    
    %% Properties
    properties (GetAccess = public, SetAccess = private)
        string,prop
    end
    
    methods (Access = public)
        function obj = Checkbox(string, varargin)
            obj.string = string;
            obj.prop = varargin;
        end
        function h = plot(obj)
            h = uicontrol('Style','checkbox',...
                'String',obj.string,...
                'Value',false,obj.prop{:});
            
            h.Position= obj.Position;
            h.Callback= obj.Callback;
            
            text(obj,inputname(1));
        end
    end
    
    %%
    methods (Static)
        %   Popmenu.val(h);
        function value = val(h)
            value = (get(h,'Value') == get(h,'Max'));
        end
    end
    
end% classdef