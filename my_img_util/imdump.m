function  imdump(level, varargin)
%imdump write image or figure specified by handle to file.

global saveEps;
global dumpPath;
global dumpLevel; %global offDump;

% 0 - no dump
% 1 - + overall results (no debug info)
% 2 - + main processing pipeline
% 3 - + images

    if ~isscalar(level) || isa(level, 'matlab.ui.Figure')
        error('Specify the dump level.')
    end

    if level > dumpLevel
        return; % Default: on dump
    end
    
    debug = level > 1;
    
    if ~isempty(dumpPath)
        dumpPath = [dumpPath '/'];
    end
   
    for i = 2:nargin
        param = varargin{i-1};
        
        if debug  % carry with some debug info
            % st(1): imdump st(2): function which called imdump
            st = dbstack;
            if length(st) > 1, n = 2; else n = 1; end

            funcname = st(n).name;
            line = st(n).line;
            debuginfo = [inputname(i), ' @', funcname, '-', num2str(line)];
        end

        if 1 == length(param) && ishandle(param) %% handle
            handle = param;
            figure(handle); % switch to that figure.
            
            if ~debug
                filename = handle.Name;
                if isempty(filename), filename = handle.Number; end
            else
                filename = debuginfo;
            end
            
            if saveEps
                print([dumpPath, filename, '.eps'],'-depsc');
            else
                print(handle, '-djpeg', [dumpPath filename]);
            end

        else %% image
            image = param;
            
            if ~debug
                filename = inputname(i);
            else
                filename = debuginfo;
            end

            if saveEps
                h = figure; imshow(image);
                print([dumpPath, filename, '.eps'],'-depsc');
                close(h);
            else
                imwrite(image, [dumpPath filename, '.jpg']);
            end
        end
    end
end
    
