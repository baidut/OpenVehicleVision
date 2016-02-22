classdef Ui
    %UI make it easier to test params of function
    %
    %   Example
    %   -------
    %       I = imread('circuit.tif');
    %
    %       subplot(121);
    %       imshow(I);
    %       image = struct('style','image','h',gca); % style must be lower case
    %       thresh = struct('style','slider','min',0,'max',1,'value',0.5);
    %       subplot(122);
    %       % BW = edge(I,'sobel',THRESH)
    %       Ui.imshow(gca, @edge, image, 'sobel', thresh);
    %
    %   Project website: https://github.com/baidut/openvehiclevision
    %   Copyright 2016 Zhenqiang Ying.
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Static methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %TODO
    % rearrange the position after window resized.
    
    methods (Static)
        function h = imshow(func, varargin)
            % default value
            h = gca;
            n_fixarg = nargin - numel(varargin);
            % init variables
            cnt = 0;
            uictrls = cell(1,numel(varargin));
            isuictrls = zeros(1,numel(varargin));
            values = cell(1,numel(varargin));
            pos = h.Position .* [560 420 0 0];
            for n = 1:numel(varargin)
                arg = varargin{n};
                if isstruct(arg) % BUG: some function may take struct as an input
                    cnt = cnt + 1;
                    switch lower(arg.style)
                        case 'slider'
                            uicontrol('style','text',...
                                'position',pos + [0 0 60 15],...
                                'string',inputname(n+n_fixarg));
                            values{cnt} = uicontrol('style','text',...
                                'position',pos + [0 -15 60 15],...
                                'string',inputname(n+n_fixarg));
                            uictrls{cnt} = uicontrol('style','slider',...
                                    'position',pos + [60 -15 120 30]...
                                 );
                        case 'popup'
                            uictrls{cnt} = uicontrol('style','popup');
                            
                            % additional ui controls
                        case 'image'
                            uictrls{cnt} = arg.h;
                        case 'rangeslider'
                        otherwise
                            disp('Unknown ui control style.');
                    end
                    % add other properties of uictrls{cnt}
                    switch lower(arg.style)
                        case {'slider','popup'}
                            isuictrls(cnt) = true;
                            fields = fieldnames(arg);
                            for n = 2:numel(fields) % style must be the first field
                                set(uictrls{cnt}, fields{n}, arg.(fields{n}));
                            end
                    end
                end
                % init uictrls done, add callback
                for n_cnt = 1:cnt
                    if isuictrls(n_cnt)
                        set(uictrls{n_cnt},'callback',@(h,e)callback_func());
                    end
                end
                
                % call once
                callback_func();
            end
            
            function callback_func()
                % shared args: h,uictrls,func,varargin{:},values
                % load the value of uicontrols
                
                titlestr = [char(func) '('];
                idx = 0;
                args = varargin;
                for m = 1:numel(args)
                    if isstruct(args{m})
                        idx = idx + 1;
                        switch lower(args{m}.style)
                            case {'popup'}
                                args{m} = get(uictrls{idx},'value');
                            case 'slider'
                                args{m} = get(uictrls{idx},'value');
                                set(values{idx},'string',num2str(args{m}));%,'%2.2f'
                                
                            case 'image'
                                args{m} = getimage(uictrls{idx});
                            case 'rangeslider'
                            otherwise
                                disp('Unknown ui control style.');
                        end
                    end
                    
                    if ischar(args{m})
                        titlestr = sprintf('%s''%s'',',titlestr,args{m});
                    elseif isscalar(args{m})
                        titlestr = [titlestr num2str(args{m}) ','];
                    else
                        disp('Unknown arg type.');
                    end
                end
                result = func(args{:});
                axes(h);
                imshow(result);
                
                %TODO:use txt instead of title to avoid conflict
                titlestr = [titlestr(1:end-1) ')'];
                title(titlestr);
                %title(sprintf('%s(%)') char(func) ) 
            end
            
        end
        
    end% methods
end% classdef