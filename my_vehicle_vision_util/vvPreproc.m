classdef vvPreproc
    %VVPREPROC do image pre-processing
    %
    %   Example
    %   -------
    %   %  Call static methods.
    %      I = imread('K:\Documents\MATLAB\dataset\roma\BDXD54\IMG00006.jpg');
    %      J = vvPreproc.deblock(I);
    %      imshow(J);
    %
    %   Project website: https://github.com/baidut/openvehiclevision
    %   Copyright 2016 Zhenqiang Ying.
    
    % Todo
    % Color correction - White Balance Correct
    
    %% Public properties
    % properties (GetAccess = public, SetAccess = private)
    % end
    
    %% Static methods
    methods (Static)
        
        %% distortion caused by illumination effects
        % deshadow, illuminate-invarient feature
        % usage: %s sigma k min input(ppm) output(ppm)
        
		% seg has been moved to vvSeg module
        
        %% distortion caused by noise
        function ImgProc = denoise(ImgRaw)
            % Noise Removal http://cn.mathworks.com/help/images/noise-removal.html
            % todo: denoise test app
            ImgProc = wiener2(ImgRaw,[5 5]);
        end
         %% distortion caused by Bayer filter
         function ImgProc = debayer(ImgRaw)
            % https://en.wikipedia.org/wiki/Bayer_filter
            % matlab demosaic process a raw RBBG format image to be smooth
            % dabayer process a processed RBBG image.
            % Bayer Encoding for Color Images is used for image compression
            % see http://www.ni.com/white-paper/3903/en/
            
            % the specific format(gbrg or grbg) is not known, we must do some testing.
            [XXXR,XGGX,BXXX,] = getChannel(ImgRaw);
            
            % B  G1
            % G2 R
            B = BXXX(1:2:end,1:2:end);
            R = XXXR(2:2:end,2:2:end);
            G1 = XGGX(1:2:end,2:2:end);
            G2 = XGGX(2:2:end,1:2:end);
            
            
            % check bayer filter
            
         end  
        %% distortion caused by camera
        function ImgProc = debarrel(ImgRaw, k, varargin)
            % remove barrel distortion
            % TODO: if k is not given, then open GUI for debarreling
            % foreach_file_do('%datasets\pku\1\*.jpg', @(f)imwrite(vvPreproc.debarrel(imread(f),-0.19),['%Temp/debarrel_' vvFile.name(f) '.jpg']));
            % or oo coding style
            % Files = vvFile('%datasets\pku\1\*.jpg');
            % Files.foreach(@(f)imwrite(vvFlow.pipeline(f, @imread, @vvPreproc.debarrel), vvFile.name(f)))
            if nargin < 2
                if nargout ~= 0
                    error('k must be given when using debarrel');
                end
                subplot(1,2,1);
                imshow(ImgRaw);title('I');
                subplot(1,2,2);
                imshow(ImgRaw);
                hsl = uicontrol('Style','slider',...
                    'Min',-1,'Max',1,'Value',0,...
                    'SliderStep',[0.01 0.10],...
                    'Position',[20 20 200 20]);
                set(hsl,'Callback',@(hObject,eventdata) { ...
                    imshow(vvPreproc.debarrel(ImgRaw,get(hObject,'Value'))), ...
                    title(num2str(get(hObject,'Value'),'vvPreproc.debarrel(I,%.2f)')) ...
                    });
            else
                ImgProc = lensdistort(ImgRaw, k, varargin{:});
            end
        end
        
        %% distortion casused by position
        function ImgProc = derotate(ImgRaw, angle)
            % imrotate(I,-1);
            ImgProc = imrotate(ImgRaw, angle);
        end
        %% distortion caused by image compression algorithm
        function ImgProc = deblock(ImgRaw)
            %ImgProc = imgaussfilt(ImgRaw, 2);
            ImgProc = imgaussfilt(ImgRaw, 2);
        end
        
    end% methods
end% classdef