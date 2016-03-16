classdef ColorImg<handle
    %COLORIMG encapsulates image arithmetic via operator overloading
    %TODO: add imadd imsub overwrite
    % Multi-Channel Image.
    
    %% Public properties
    properties (GetAccess = public, SetAccess = private)
        data
        rows,cols,chns
    end
    
    %% TODO
    % ui
    % roi imcrop imrect imroi
    % impoint imline impoly imellipse imfreehand
    
    %% Public methods
    methods (Access = public)
        
        function I = ColorImg(Image)
            if ischar(Image), Image = imread(Image); end
            I.data = Image;
            [I.rows, I.cols, I.chns] = size(I.data);
        end
        
        function [varargout] = eachChn(I, func)
            % I = RawImg('peppers.png');
            % [R G B] = I.eachChn();
            % Fig.subimshow(I, R, G, B);
            if nargin < 2
                func = @(x)x;
            end
            
            %no need to use arrayfun since the #chn is not big
            varargout = cell(I.chns,1);
            for n = 1:I.chns
                varargout{n} = func(I.data(:,:,n));
            end
        end
        
        function chnImg = channel(obj, c)
            % RGB HSV YCbCr Lab YIQ
            switch lower(c)
                case {'r','h','y','l'}
                    chnImg = obj.data(:,:,1);
                case {'g','s','cb','a','i'}
                    chnImg = obj.data(:,:,2);
                case {'b','v','cr','q'}
                    chnImg = obj.data(:,:,3);
                otherwise
                    error('Not a valid channel');
            end
        end
        
        function setChannel(obj, c, value)
            switch lower(c)
                case {'r','h','y','l'}
                    obj.data(:,:,1) = value;
                case {'g','s','cb','a','i'}
                    obj.data(:,:,2) = value;
                case {'b','v','cr','q'}
                    obj.data(:,:,3) = value;
                otherwise
                    error('Not a valid channel');
            end
        end
        
        %% Image Arithmetic
        function c = plus(a,b)
            c = ColorImg(imadd(a.data, b.data));
        end
        
        function c = minus(a,b)
            c = ColorImg(imsubtract(a.data, b.data));
        end
        
        function c = uminus(a)
            c = ColorImg(imcomplement(a.data));
        end
        
        function c = uplus(a)
            c = a.data;
        end
        
        % useless
        function c = ctranspose(a)
            c = flip(imrotate(a, 90), 1);
        end
        function c = times(a)
            c = ColorImg(immultiply(a.data, b.data));
        end
        
        %% behave like normal image with power-up features
        function out=end(A,k,n)
            out=builtin('end',A.data,k,n);
        end
        function varargout = subsref(obj,s)
            % I = ColorImg('peppers.png')
            % imshow(I.R)
            % imshow(I.G(1:2:end, 1:2:end))
            
            switch s(1).type
                case '.'
                    if length(s) == 1
                        % Implement obj.PropertyName
                        varargout{1} = obj.channel(s(1).subs);
                    elseif length(s) == 2
                        % Implement obj.PropertyName(indices)
                        chnImg = obj.channel(s(1).subs);
                        varargout{1} = chnImg(s(2).subs{:});
                    else
                        varargout = {builtin('subsref',obj,s)};
                    end
                case '()'
                    varargout{1} = builtin('subsref',obj.data,s);
                    % imshow(I(1:2:end, 1:2:end, :).R(1:2:end, 1:2:end))
                    %                     if length(s) == 1
                    %                         % Implement obj(indices)
                    %                         varargout{1} = obj.data(s(1).subs{:});
                    %                     elseif length(s) == 2 && strcmp(s(2).type,'.')
                    %                         % Implement obj(ind).PropertyName
                    %                         chnImg = obj.channel(s(2).subs);
                    %                         varargout{1} = chnImg(s(1).subs{:});
                    %                     elseif length(s) == 3 && strcmp(s(2).type,'.') && strcmp(s(3).type,'()')
                    %                         % Implement obj(indices).PropertyName(indices)
                    %                         im = ColorImg(obj.data(s(1).subs{:}));
                    %                     	chnImg = im.channel(s(2).subs);
                    %                         varargout{1} = chnImg(s(3).subs{:});
                    %                     else
                    %                         % Use built-in for any other expression
                    %                         varargout = {builtin('subsref',obj,s)};
                    %                     end
                case '{}'
                    error('MyDataClass:subsasgn',...
                        'Not a supported subscripted assignment')
                    
                    % I{r,c} return pixel(3*1) in (r,c)
                    % % I(r,c,:) return 1*1*3 vector
                    if length(s) == 1
                        % Implement obj{indices}
                        ...
                            
                    elseif length(s) == 2 && strcmp(s(2).type,'.')
                        % Implement obj{indices}.PropertyName
                        ...
                            
                    else
                        % Use built-in for any other expression
                        varargout = {builtin('subsref',obj,s)};
                    end
                otherwise
                    error('Not a valid indexing expression')
            end
        end
        function obj = subsasgn(obj,s,varargin)
            %% copy object of same class
            if isempty(s) && isa(val,'ColorImg')
                obj = ColorImg(val.data);
            end
            
            switch s(1).type
                case '.'
                    if length(s) == 1
                        % Implement obj.PropertyName = varargin{:};
                        obj.setChannel(s(1).subs,varargin{1});
                    elseif length(s) == 2 && strcmp(s(2).type,'()')
                        % Implement obj.PropertyName(indices) = varargin{:};
                        ...
                            
                    else
                        % Call built-in for any other case
                        obj = builtin('subsasgn',obj,s,varargin);
                    end
                case '()'
                    if length(s)<2
                        if isa(val,'ColorImg')
                            error('MyDataClass:subsasgn',...
                                'Object must be scalar')
                        else
                            % Redefine the struct s to make the call: obj.Data(i)
                            snew = substruct('.','data','()',s(1).subs(:));
                            obj = subsasgn(obj,snew,val);
                        end
                    end
                case '{}'
                    error('MyDataClass:subsasgn',...
                        'Not a supported subscripted assignment')
                otherwise
                    error('Not a valid indexing expression')
            end
        end
        
        function h = imshow(I, varargin)
            h = imshow(I.data, varargin{:});
            title(inputname(1),'Interpreter','none');
        end
        
    end% methods
end% classdef