classdef Uictrl<handle
    
    properties (GetAccess = public, SetAccess = private)
        func,argName,argValue
        h_uictrls,h_axes
    end
    
    methods (Static)
        
    end
    
    methods (Access = public)
        function obj = Uictrl(func, varargin)
            obj.func = func;
            obj.argName = cell(1,numel(varargin));
            for n = 1:numel(varargin)
                obj.argName{n} = inputname(n+1);
            end
            obj.argValue = varargin;
        end
        
        function plot(obj,h_axes) % handle
            %if nargin<2, h = gca; end
            axes(h_axes);
            obj.h_uictrls = cell(1,numel(obj.argValue));
            idx = 0;
            for n = 1:numel(obj.argValue)
                arg = obj.argValue{n};
                switch class(arg)
                    case 'Uiview'
                        idx = idx + 1;
                        obj.h_uictrls{n} = arg.plot(h_axes, obj.argName{n}, idx);
                        %arg.setCallback(obj.h_uictrl{n},@(h,ev)obj.callback_func());%
                        obj.h_uictrls{n}.Callback = @(h,ev)obj.callback_func();
                    otherwise
                        % fixed param
                end%switch
            end%for
            
            obj.h_axes = h_axes;
            obj.callback_func(); % call once
            % nested callback_func is also ok
        end
        
        function callback_func(obj)
            % arg/args: read the uicontrol values
            args = obj.argValue; % do not change argValue
            
            % load args value
            fprintf(char(obj.func));
            for n = 1:numel(args)
                arg = args{n};
                switch class(arg)
                    case 'Uiview'
                        args{n} = arg.getValue(obj.h_uictrls{n});%
                        %args{n} = obj.h_uictrls{n}.Value;
                    otherwise
                        % fixed param
                end%switch
                %str = [str evalc('disp(arg)') ','];
                if n == 1, fprintf('(');
                else fprintf(',');
                end
                if isscalar(args{n}), fprintf('%f',args{n}); 
                elseif ischar(args{n}), fprintf('''%s''',args{n}); 
                else fprintf('%s',obj.argName{n});
                end
            end%for
            
            %if gca ~= h, axes(h);end
            %hold on; % keep the title
            fprintf(');\n');
            imshow(obj.func(args{:}),'Parent',obj.h_axes);
        end
    end% methods
end% classdef