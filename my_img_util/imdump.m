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
    
    if ~isempty(dumpPath)
        dumpPath = [dumpPath '/'];
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
                print([dumpPath, filename debuginfo, '.eps'],'-depsc');
            else
                print(handle, '-djpeg', [dumpPath filename debuginfo]);
            end

        else %% image
            image = param;

            if saveEps
                h = figure; imshow(image);
                print([dumpPath, filename debuginfo, '.eps'],'-depsc');
                close(h);
            else
                imwrite(image, [dumpPath filename debuginfo, '.jpg']);
            end
        end
    end
end
    
