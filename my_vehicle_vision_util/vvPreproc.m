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
    
    %% Public properties
    % properties (GetAccess = public, SetAccess = private)
    % end
    
    %% Static methods
    methods (Static)
        
        %% distortion caused by illumination effects
        % deshadow, illuminate-invarient feature
        
        function Iseg = superpixel(I)
            ratio = 0.5;
            kernelsize = 2;
            maxdist = 10;
            
            Iseg = vl_quickseg(I, ratio, kernelsize, maxdist);
        end
        
        function segments = slicSuperpixel(ImgRaw)
            %http://www.vlfeat.org/overview/slic.html            
            % im contains the input RGB image as a SINGLE array
            
            % IMAGE is not of class SINGLE.
            im = im2single(ImgRaw);
            
            regionSize = 10 ;
            regularizer = 10 ;
            % IM contains the image in RGB format as before
            %imlab = vl_xyz2lab(vl_rgb2xyz(im)) ;
            %imlab = im2single(imlab);
            imlab = im;
            segments = vl_slic(imlab, regionSize, regularizer);
        end
        
        %% distortion caused by camera
        function ImgProc = debarrel(ImgRaw, k)
            % remove barrel distortion
            % TODO: if k is not given, then open GUI for debarreling
            % foreach_file_do('%datasets\pku\1\*.jpg', @(f)imwrite(vvPreproc.debarrel(imread(f),-0.19),['%Temp/debarrel_' vvFile.name(f) '.jpg']));
            % or oo coding style
            % Files = vvFile('%datasets\pku\1\*.jpg');
            % Files.foreach(@(f)imwrite(vvFlow.pipeline(f, @imread, @vvPreproc.debarrel), vvFile.name(f)))
            if nargin < 2
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
                ImgProc = lensdistort(ImgRaw, k);
            end
        end
        %% distortion caused by image compression algorithm
        function ImgProc = deblock(ImgRaw)
            %ImgProc = imgaussfilt(ImgRaw, 2);
            ImgProc = imgaussfilt(ImgRaw, 2);
        end
        
    end% methods
end% classdef