classdef vvRoadSeg < handle
    %%VVBOUNDEXTRACTOR implements the road boundary extraction module of VV lib.
    % an color image ---> a binary image indicating road region
    %
    %   Example
    %   -------
    %   %  Test road segmantation.
    %      colorImage = imread('K:\Documents\MATLAB\dataset\roma\BDXD54\IMG00006.jpg');
    %      RoadSeg = vvRoadSeg(colorImage);
    %      RoadRegion = RoadSeg.result();
    %      imshow(RoadRegion);
    %
    %   Project website: https://github.com/baidut/openvehiclevision
    %   Copyright 2016 Zhenqiang Ying.
    
    properties(GetAccess = public, SetAccess = private)
        RawImg
        VP %vanishingPoint
    end
    
    methods
        function RoadSeg = vvRoadSeg(Img, vanishingPoint)
            RoadSeg.RawImg = Img;
            [rows, cols, chns] = size(Img);
            
            if chns ~= 3
                error('color image is needed');
            end
            
            if nargin < 2
                RoadSeg.VP = [cols/2, rows/3];
            else
                RoadSeg.VP = vanishingPoint;
            end
            
        end
        
        function RoadRegion = result(RoadSeg)
            Img = RoadSeg.RawImg;
            
            nColSplit = floor(RoadSeg.VP(1));
            nRowSplit = floor(RoadSeg.VP(2));
            nHorizon = floor(RoadSeg.VP(2));
            
            %% Preprocessing - deblock
            BlurImg = imgaussfilt(Img, 2);
            
            %% Extract feature map. (the probablity of being a boundary point.
            featureMap = vvFeature.S2(BlurImg); % featureExtractionByRpGm2B
            roadSegL = RoadSeg.segByOtsu(featureMap(nRowSplit:end, 1:nColSplit,:));
            roadSegR = RoadSeg.segByOtsu(featureMap(nRowSplit:end, nColSplit+1:end,:));
            
            RoadRegion = [zeros(nHorizon-1, size(BlurImg,2)); ...
                roadSegL, roadSegR];
        end
    end
    
    %% Static methods
    % Static methods are associated with a class, but not with specific instances of that class.
    % S2feature = vvRoadSeg.S2(Img);
    methods(Static)
        %% Segmentation
        % a grayscale image ---> a color image
        
        function BW_Filtered = seg(Gray)
            BW = Gray > 2 * mean(Gray(:)); % 2.5 * mean(Gray(end,:));0.15 * max(Gray(:));0.3 0.2
            %BW_imclose = imclose(BW, strel('square',3)); %imdilate imclose imopen
            BW_areaopen = bwareaopen(BW, 200, 4);  % 60
            BW_Filtered = BW_areaopen;
        end
        
        function BW_Filtered = segByOtsu(GrayImg)
            BW = im2bw(GrayImg, graythresh(GrayImg)+0.1); % 0.06 +
            %BW_imclose = imclose(BW, strel('square', 5)); %imdilate imclose imopen
            BW_areaopen = bwareaopen(BW, 230, 4);
            BW_Filtered = BW_areaopen;
        end
        
        function BW_Filtered = segByFixedThresh(GrayImg)
            GrayImg = mat2gray(GrayImg); % 0 - 1
            BW = (GrayImg < 0.58 ) .* (GrayImg > 0.52) ;
            %BW_imclose = imclose(BW, strel('square', 5)); %imdilate imclose imopen
            BW_areaopen = bwareaopen(BW, 230, 4);
            BW_Filtered = BW_areaopen;
        end
        
        function BW = segByEdge(GrayImg, isleft)
            H = [ 1,  0,  0,  0, -1;
                1,  0,  0,  0, -1;
                4,  2,  0, -2, -4;
                1,  0,  0,  0, -1;
                1,  0,  0,  0, -1];
            
            if ~isleft
                H = -H;
            end
            EdgeFeature = imfilter(GrayImg,H,'replicate');
            BW = im2bw(EdgeFeature,graythresh(EdgeFeature));
            imdump(BW,EdgeFeature);
        end
    end
end