classdef Uictrl<handle

    properties (GetAccess = public, SetAccess = private)
		func,argName,argValue
    end
	
	methods (Static)
	end

    methods (Access = public)
        %% constructors
		function obj = Uictrl(func, varargin)
			obj.func = func;
			%obj.argName = inputname();
			obj.argValue = varargin;
        end
		
		function plot(obj,h) % handle
			axes(h);
			
			for n = 1:numel(obj.argValue) 
				arg = obj.argValue{n};
				switch class(arg)
					case 'Uiview'
						arg.plot(h);
						arg.setCallback(@(h,e)callback_func());
					otherwise
						% fixed param
				end%switch
			end%for
			
			callback_func(); % call once
			
			function callback_func()
			% arg/args: read the uicontrol values
			
				args = obj.argValue; % do not change argValue
				
				% load args value
				for n = 1:numel(args) 
					arg = args{n};
					switch class(arg)
						case 'Uiview'
							args{n} = arg.val();
						otherwise
							% fixed param
					end%switch
				end%for
				
				result = obj.func(args{:});
				axes(h);
				hold on; % keep the title
				imshow(result);
				
			end
		end
    end% methods
end% classdef