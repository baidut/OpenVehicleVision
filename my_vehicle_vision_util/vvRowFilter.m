classdef vvRowFilter < handle
    %VVROWFILTER provide Zhenqiang YING's implementation of following
    %paper:
    %
    % T.Veit, J.-P.Tarel, P.Nicolle, andP. Charbonnier, ¡°Eval- uation of
    % road marking feature extraction,¡± in Intelligent Transportation
    % Systems, 2008. ITSC 2008. 11th Interna- tional IEEE Conference on,
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
        %% 1D filters
        % s - size must be an integer
        function res = LT(im, s) % mean filter
            res = imfilter(im, ones(1, s)/double(s), 'corr', 'replicate');
            % ones(1, s)/s fail if s is not double
        end
        function res = MLT(im, s) % median filter
            res = medfilt2(im, [1, s]);
        end
        function res = SLT(im, s)
            res = imfilter(im, ones(1, s)/double(s), 'corr', 'replicate');
        end
        function res = SMLT(im, s)
            res = medfilt2(im, [1, s]);
        end
        
        function resImg = eachRow(rawImg, func, s_range, horizon)
            resImg = rawImg; %zeros(size(rawImg), 'like', rawImg);
            horizon = round(horizon);
            
            roiImg = rawImg(horizon+1:end,:);
            ratio = (s_range(2) - s_range(1)) / size(roiImg, 1);
            
            for r = 1 : size(roiImg,1)
                resImg(horizon+r,:) = func(roiImg(r,:), ceil(s_range(1) + r*ratio));
            end
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