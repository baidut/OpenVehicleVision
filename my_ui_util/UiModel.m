classdef UiModel < handle
    methods (Static)
		function value = val(h)
			value = h.Value;
		end
		function call(h, func)
			h.Callback = func;
		end
    end
end% classdef