classdef vvSeg
    %TODO: matlab support slic superpixels [Introduced in R2016a]
    %VVSEG do image segmentation
    %
    %   Example
    %   -------
    %
    %   Project website: https://github.com/baidut/openvehiclevision
    %   Copyright 2016 Zhenqiang Ying.
    
    %% Public properties
    % properties (GetAccess = public, SetAccess = private)
    % end
    
    %% Static methods
    
    %% Superpixel
    methods (Static)
        function Iseg = quickshift(I,ratio,kernelsize,maxdist)
            % TODO Multiple segmentations
            % http://www.vlfeat.org/overview/quickshift.html
            if nargin < 4
                maxdist = 10;
                if nargin < 3
                    kernelsize = 2;
                    if nargin <2
                        ratio = 0.5;
                    end
                end
            end
            
            Iseg = vl_quickseg(I, ratio, kernelsize, maxdist);
        end
        
        function labelImg = slic(ImgRaw)
            % note the output segments is not an rendered image, use superpixel
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
            labelImg = LabelImg(segments);
			if nargout == 0, imshow(labelImg); end
        end
        
        %% Segmentation
        function labelImg = felzen(Img, sigma, k, min)
		% run demo: vvSeg.felzen
			if nargout == 0 && nargin < 2
				if nargin < 1
					Img = imread('F:\Documents\pku-road-dataset\1\EMER0009\0379.jpg');
                end
                sigma = Slider([0 3]);
                k = Slider([1 1000]);
                min = Slider([1 size(Img,1)*size(Img,2)/20]);
                
                felzen = @(im,sigma,k,min)label2rgb(+vvSeg.felzen(im,sigma,k,min));
                seg = ImCtrl(felzen, Img, sigma, k, min);
                
				F = Fig;
                F.maximize();
                F.subimshow(Img, seg);
				return;
			end
		
            if nargin < 4, min = 50;
                if nargin < 3, k = 500;
                    if nargin < 2, sigma = 0.5;
                    end
                end
            end
			 
            segments = mexFelzenSegmentIndex(Img, sigma, k, min);
			labelImg = LabelImg(segments);
			if nargout == 0, imshow(labelImg); end
		end
		
        function RGB = visualize(Seg_label)
            RGB = label2rgb(Seg_label);
        end
    end% methods
end% classdef
