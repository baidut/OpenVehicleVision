classdef Lib
    %TODO: Lib manager, auto watch thirdparty folder
    %
    %   Project website: https://github.com/baidut/openvehiclevision
    %   Copyright 2016 Zhenqiang Ying.
    
    % Requirement: GetFullPath
    
    properties
        rootpath
        name
    end
  
    methods (Access = public)
        function Lib = Lib(varargin)
            if numel(varargin) == 0
                Lib.rootpath = cd;
            else
                if numel(varargin) == 1
                    filePath = varargin{1}; % avoid fullfile convert '/' to '\'
                else
                    filePath = fullfile(varargin{:});
                end
                Lib.name = filePath(find(filePath=='\',1,'last')+1:end);
                Lib.rootpath = GetFullPath(filePath);
            end
            % Lib.rootpath
        end
        %%
        function enabled = isEnabled(Lib) % checkIfEnabled
            paths = strsplit(path,';');
            enabled = ~isempty(find(strcmp(paths,Lib.rootpath),1));
        end
        
        function disable(Lib)
            rmpath(genpath(Lib.rootpath));
        end
        
        function enable(Lib)
            addpath(genpath(Lib.rootpath));
        end
        %%
        function disp(Lib)
            codeCd2Path = sprintf('matlab: cd ''%s''',Lib.rootpath);
            codeEnableLib = sprintf('matlab: l=Lib(''%s'');l.enable();startup',Lib.rootpath);
            codeDisableLib = sprintf('matlab: l=Lib(''%s'');l.disable();startup',Lib.rootpath);
           
            if Lib.isEnabled()
                fprintf('[on/<a href="%s">off</a>]',codeDisableLib);
            else
                fprintf('[<a href="%s">on</a>/off]',codeEnableLib);
            end
            
            fprintf(' <a href="%s">%s</a>\n',codeCd2Path, Lib.name);
        end
    end
    
    methods (Static)
        function dispLibStatus(folder)
            folders = subfolder(folder);
            folders = strcat([folder '\'], folders);
            for n = 1:numel(folders)
                lib = Lib(folders{n});
                disp(lib);
            end
        end
    end
end