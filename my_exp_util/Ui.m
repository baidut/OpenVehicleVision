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
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Static methods
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Static)
        function imshow(h, func, varargin)
			cnt = 0;
            uictrls = cell(1,numel(varargin));
			isuictrls = zeros(1,numel(varargin));
			for n = 1:numel(varargin)
				arg = varargin{n};
				if isstruct(arg)
					cnt = cnt + 1;
					switch lower(arg.style)
						case 'slider'
							uictrls{cnt} = uicontrol('style','slider');
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
				for n = 1:cnt
					if isuictrls(n)
						set(uictrls{n},'callback',@(h,e)callback_func(uictrls,func,varargin{:}));
					end
				end
				
				% call once
				callback_func(uictrls,func,varargin{:});
			end
			
			function callback_func(uictrls,func,varargin)
				
				% load the value of uicontrols
				idx = 0;
				args = varargin;
				for n = 1:numel(args)
					arg = args{n};
					if isstruct(arg)
						idx = idx + 1;
						switch lower(arg.style)
							case {'popup','slider'}
								args{n} = get(uictrls{idx},'value');
							case 'image'
								args{n} = getimage(uictrls{idx});
							case 'rangeslider'
							otherwise
								disp('Unknown ui control style.');
						end
					end
				end
				result = func(args{:});
				axes(h);
				imshow(result);
				
				%use txt instead of title to avoid conflict
				%TODO
			end
			
        end

    end% methods
end% classdef