classdef vvFile 
    methods (Static)
        function filename = name(file) 
			[~,filename,~] = fileparts(file);
        end
    end
end