classdef exDebugger
    % EXDEBUGGER
    
    properties (Constant)
        
        
    end
    properties
        dumper
    end
    
    methods (Access = public)
        function obj = exDebugger(varargin)
            % config dumper
            cfg = struct(varargin{:});
            
            defaultCfg.path = '%dump/';
            defaultCfg.level = 1; %error
            defaultCfg.saveAsEps = false;
            
            cfg = loaddefault(cfg, defaultCfg); % cfg.loaddefault
            
            cfg.path = [cfg.path '/'];
            
            obj.dumper = cfg;
        end
        
        
        function implot(obj, level, varargin)
            % d = exDebugger('level',4);
            % cameraman = imread('cameraman.tif');
            % peppers = imread('peppers.png');
            % d.implot(4,cameraman,peppers);
            if level > obj.dumper.level
                return; % Default: on dump
            end
            
            Fig.subimshow(varargin{:});
            titles = cell([1 numel(varargin)]);
            for n = 1:numel(varargin)
                titles{n} = inputname(n+nargin-numel(varargin));
            end
%             hold on;
%             Fig.eachsubplot(@(x)x, varargin, titles);
        end
        
        function imdump(obj, level, varargin)
            %imdump write image or figure specified by handle to file.
            % 'dumper.level'   -  determine how much information to be displayed. (default is 1)
            %                     0 : no display, only output result to file (release)
            %                     1 : errors
            %                     2 : + warnings
            %                         + dump main results
            %                     3 : + show main figure (debug, time consuming)
            %                     4 : + output intermediate results (when encountering bugs)
            %                     5 : + progression (progressbar)
            %                     6 : + information (disp more information)
            if ~isscalar(level) || isa(level, 'matlab.ui.Figure')
                error('Specify the dump level.')
            end
            
            if level > obj.dumper.level
                return; % Default: on dump
            end
            
            for i = 2:nargin
                param = varargin{i-1};
                filename = inputname(i);
                if level <= 1 %(no debug info)
                    debuginfo = '';
                else
                    % carry with some debug info
                    % st(1): imdump st(2): function which called imdump
                    st = dbstack;
                    if length(st) > 1, n = 2; else n = 1; end
                    
                    funcname = st(n).name;
                    line = st(n).line;
                    debuginfo = [' @', funcname, '-', num2str(line)];
                end
                
                if 1 == length(param) && ishandle(param) %% handle
                    handle = param;
                    figure(handle); % switch to that figure.
                    
                    if isempty(filename), filename = handle.Name; end
                    if isempty(filename), filename = handle.Number; end
                    
                    if saveEps
                        print([obj.dumper.path, filename debuginfo, '.eps'],'-depsc');
                    else
                        print(handle, '-djpeg', [obj.dumper.path filename debuginfo]);
                    end
                    
                else %% image
                    image = param;
                    
                    if obj.dumper.saveAsEps
                        h = figure; imshow(image);
                        print([obj.dumper.path, filename debuginfo, '.eps'],'-depsc');
                        close(h);
                    else
                        imwrite(image, [obj.dumper.path filename debuginfo, '.jpg']);
                    end
                end
            end
        end
    end
end
