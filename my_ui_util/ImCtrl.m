classdef ImCtrl<handle
    
    properties (GetAccess = public, SetAccess = private)
        func,argName,argValue
        h_uictrls,h_axes
        h_dst = {}
        args_imshow
    end
    
    methods (Static)
    end
    
    methods (Access = public)
        function obj = ImCtrl(func, varargin)
            nargfixed = nargin - numel(varargin);
            obj.func = func;
            obj.argName = cell(1,numel(varargin));
            for n = 1:numel(varargin)
                obj.argName{n} = inputname(n+nargfixed);
            end
            obj.argValue = varargin;
        end
        
        function addCall(obj, func)
            obj.h_dst{end+1} = func;
        end
        
        function removeCall(obj, func)
            % maybe buggy
            obj.h_dst{obj.h_dst==func} = [];
        end
        
        function imshow(obj,varargin) % handle
            obj.h_uictrls = cell(1,numel(obj.argValue));
            obj.args_imshow = varargin;
            idx = 0;
            for n = 1:numel(obj.argValue)
                arg = obj.argValue{n};
                if isobject(arg) %&& superclass(arg)
                    idx = idx + 1;
                    
                    %TODO: if Position is not set
                    %TODO: panel or child figure
                    %NOTE: Axes cannot be a parent.
                    f = gcf;
                    a = gca;
                    
                    % put uicontrol on the downside of axes
                    height = 20;
                    width = 180;
                    pos = a.Position .* [f.Position(3:4) 0 0] + [-100 50 0 0];
                    arg.Position = pos + [120 -height*idx width height];
                    arg.Callback = @(h,ev)obj.update();
                    
                    % plot
                    if isempty(obj.argName{n})
                       obj.argName{n} = class(obj.argValue{n}); 
                    end
                    eval(sprintf('%s=arg;',obj.argName{n}));
                    eval(sprintf('obj.h_uictrls{n} = %s.plot(obj);',obj.argName{n}));
                end
            end%for
            
            obj.h_axes = gca;
            obj.update(); % call once
        end
        
        function update(obj)
            % We turn the interface off for processing.
%             InterfaceObj=findobj(obj.h_axes,'Enable','on');
%             set(InterfaceObj,'Enable','off');

            % arg/args: read the uicontrol values
            args = obj.argValue; % do not change argValue
            
            % load args value
            fprintf(char(obj.func));
            for n = 1:numel(args)
                arg = args{n};
                
                % get value of uicontrols
                if isobject(arg) %&& superclass(arg)
                    args{n} = arg.val(obj.h_uictrls{n});
                end
                
                if n == 1
                    fprintf('(');
                else
                    fprintf(',');
                end
                
                str = tostring(args{n});
                if isempty(str)
                    fprintf('%s',obj.argName{n});
                else
                    fprintf('%s',str);
                end
            end%for
            
            %if gca ~= h, axes(h);end
            %hold on; % keep the title
            fprintf(');\n');
            
            holdstat = ishold;
            hold on;
            
            % clear 
            cla(obj.h_axes);
            
            imshow(obj.func(args{:}),'Parent',obj.h_axes, obj.args_imshow{:});
            if ~holdstat, hold off; end
            
            for d = obj.h_dst
                d{1}.update(); % Callback
            end
            
            % We turn back on the interface
%             set(InterfaceObj,'Enable','on');
        end
    end% methods
end% classdef