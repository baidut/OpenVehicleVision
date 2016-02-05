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
        function ImgProc = deblock(ImgRaw)
            %ImgProc = imgaussfilt(ImgRaw, 2);
            ImgProc = imgaussfilt(ImgRaw, 2);
        end
        
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
    end% methods
end% classdef