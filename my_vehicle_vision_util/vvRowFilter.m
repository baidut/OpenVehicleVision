classdef vvRowFilter < handle
    %VVROWFILTER provide Zhenqiang YING's implementation of following
    %paper:
    %
    % T.Veit, J.-P.Tarel, P.Nicolle, andP. Charbonnier, "Evaluation of
    % road marking feature extraction," in Intelligent Transportation
    % Systems, 2008. ITSC 2008. 11th International IEEE Conference on,
    % Oct 2008, pp. 174¨C181.
    %
    % See also vvMark.
    %
    %   Project website: https://github.com/baidut/openvehiclevision
    %   Copyright 2016 Zhenqiang Ying.
    %
    %   Example
    %
    
    % speedup: when size not change, the rows can do filtering
    % together
    % block-based filtering
    
    %% Public properties
    % properties (GetAccess = public, SetAccess = private)
    % end
    
    properties (Constant)
        % [Sm,SM] = [5cm,20cm].
        % s_min = 17;  % 5cm = 17.5 pixel
        % s_max = 70;  % 20cm = 70 pixel % 58 pixel
        
        k_min = 5;      % min kernel size
        k_max = 2*70;
        T_good = 35;    %25 is too low, fixed threshold, not the best threshold but works well
    end
    
    properties
        %         s_min,s_max
        %         thresh
        %         horizon
    end
    
    %% Constructor
    methods (Access = public)
        %         function f = vvRowFilter(s_range, horizon, thresh)
        %             f.s_min = s_range(1);
        %             f.s_max = s_range(2);
        %             f.thresh = thresh;
        %             f.horizon = horizon;
        %         end
    end
    
    %% Static methods
    methods (Static)
        function resImg = eachRow(rawImg, func, s_range)
            resImg = zeros(size(rawImg),'like', rawImg); % 'uint8');
            ratio = (s_range(2) - s_range(1)) / size(rawImg, 1);
            
            for r = 1 : size(rawImg,1)
                resImg(r,:) = func(rawImg(r,:), ceil(s_range(1) + r*ratio));
            end
        end
    end
    %% 1D filters - use demo1DFilters to find best s_range
    % s - size
    methods (Static)
        function res = L(row, s) % mean filter
            res = imfilter(row, ones(1, s)/double(s), 'corr', 'replicate');
            % ones(1, s)/s fail if s is not double
        end
        function res = ML(row, s) % median filter
            res = medfilt2(row, [1, s]);
        end
        
        function demo1DFilters(I)
            % I: image data
            if nargin < 1
                I = imread('%datasets\roma\LRAlargeur14062002\IMG00088.jpg');
                I = rgb2gray(I(429:end,:,:));
                %I = imread('%datasets\roma\BDXD54\IMG00002.jpg');
                %I = vvFeature.S2(I);
                I = impyramid(I,'reduce'); % downsample to make it faster
                I = impyramid(I,'reduce');
            end
            s_range = RangeSlider(uint8([1 200])); % 5 140 % (uint8([1 200]))
            
            L   = ImCtrl(@vvRowFilter.eachRow, I, @vvRowFilter.L,   s_range);
            ML  = ImCtrl(@vvRowFilter.eachRow, I, @vvRowFilter.ML,  s_range);
            
            fig = Fig('Demo vvRowFilter');
            fig.maximize();
            fig.subimshow(I, L, ML);
        end
    end
    %% LT, MLT, SLT and SMLT
    methods (Static)
        
        function resImg = LT(rawImg, horizon, s_range, T)
            resImg = false(size(rawImg)); % no marking over horizon line
            horizon = round(horizon);
            
            roiImg = rawImg(horizon:end,:);
            resImg(horizon:end,:) = T < roiImg - vvRowFilter.eachRow(roiImg,@vvRowFilter.L,s_range);
        end
        
        function resImg = MLT(rawImg, horizon, s_range, T)
            resImg = false(size(rawImg)); % no marking over horizon line
            horizon = round(horizon);
            
            roiImg = rawImg(horizon:end,:);
            resImg(horizon:end,:) = T < roiImg - vvRowFilter.eachRow(roiImg,@vvRowFilter.ML,s_range);
        end
        
        % symmetrical local threshold 
        % This extractor is a variant of the extractor first introduced in
        % [13], [14]. Again, every image line is processed independently in
        % a sequential fashion. On each line at position x, it consists of
        % three steps. 
        %
        % First, for each pixel at 176 s 1 ?1 Fig. 1. Top-hat filter for
        % position y, the left and right intensity averages are computed,
        % i.e the image average Ile ft(y) within ]y?6SM(x),y] and the image
        % average Iright(y) within ]y,y + 6SM(x)].
        % 
        % Second, given threshold TG, the pixels with intensity higher than
        % both TG + Ile ft and TG + Iright are selected.
        % 
        % Third, sets of connected pixels in the extraction map wider than
        % Sm(x) are considered as marking elements.
        
        function res = S(row, func, dist, s, T) % Note the two s have diff meaning
            row_left  = row(1:end-dist);
            row_right = row(dist+1:end);
            biggerThanRight = [row_left - func(row_right,s) > T, true([1 dist])];
            biggerThanLeft = [true([1 dist]), row_right - func(row_left,s) > T];
            
            res = biggerThanLeft & biggerThanRight;
        end
        
        function resImg = SLT(rawImg, horizon, s_range, T)
            resImg = false(size(rawImg)); % no marking over horizon line
            horizon = round(horizon);
            
            roiImg = rawImg(horizon:end,:);
            func = @(row,s) vvRowFilter.S(row, @L )
            resImg(horizon:end,:) = vvRowFilter.eachRow(roiImg,@vvRowFilter.S,s_range);
        end
        
        function demo(I)
            % I: image data
            if nargin < 1
                I = imread('%datasets\roma\LRAlargeur14062002\IMG00088.jpg');
                I = rgb2gray(I);
                %I = imread('%datasets\roma\BDXD54\IMG00002.jpg');
                %I = vvFeature.S2(I);
                I = impyramid(I,'reduce'); % downsample to make it faster
                I = impyramid(I,'reduce');
            end
            s_range = RangeSlider(uint8([1 200])); % 5 140 % (uint8([1 200]))
            horizon = Slider([1 size(I,1)], 'Value', 429/4);
            
            LT   = ImCtrl(@vvRowFilter.eachRow, I, @vvRowFilter.LT,   s_range, horizon);
            MLT  = ImCtrl(@vvRowFilter.eachRow, I, @vvRowFilter.MLT,  s_range, horizon);
            SLT  = ImCtrl(@vvRowFilter.eachRow, I, @vvRowFilter.SLT,  s_range, horizon);
            SMLT = ImCtrl(@vvRowFilter.eachRow, I, @vvRowFilter.SMLT, s_range, horizon);
            
            fig = Fig('Demo vvRowFilter');
            fig.maximize();
            fig.subimshow(I, LT, MLT, SLT, SMLT);
        end
    end
    
end% classdef