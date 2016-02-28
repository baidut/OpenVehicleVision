classdef vvMark
    %VVMARKFEATURE do lane feature extraction
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
        
        %% 1D filters
        % s - size
        function res = LT(im, s) % mean filter
            res = imfilter(im, ones(1, s)/s , 'corr', 'replicate');
        end
        function res = MLT(im, s) % median filter
            res = medfilt2(im, [1, s]);
        end
        function res = PLT(im, s)
        end
        function res = SLT(im, s)
        end
        function res = SMLT(im, s)
            half_s = ceil(s/2);
            Middle = medfilt2(im, [1, s]);
            Middle = [repmat(Middle(1), [1,half_s]), Middle, repmat(Middle(end), [1,half_s])];
            res = Middle(1:end-half_s*2)/2 + Middle(1+half_s*2:end)/2;
        end
        
        function res = DLD(im, s) % -1-1 1 1 1 1 -1 -1
            I = double(I); % negative numbers
            half_s = ceil(s/2);
            template_DLD = ones(1, s*2);
            template_DLD(1:half_s) = -1;
            template_DLD(half_s*3:s*2) = -1;
            res = imfilter(im, template_DLD, 'corr', 'replicate');
        end
        
        function test1dfilter(I, h, w)
            % h - horizon
            % w - lane-marking pixel width of last row
            
            [nRow, nCol, ~] = size(I);
            if nargin < 3
                w = nCol/8;
                if nargin < 2
                    h = nRow/2;
                end
            end
            
            I = double(im2gray(I));
            ROI = I(h:end,:);
            nRow = size(ROI, 1);
            
            LT = zeros(nRow, nCol);
            MLT = zeros(nRow, nCol);
            SLT = zeros(nRow, nCol);
            SMLT = zeros(nRow, nCol);
            
            for r = 1 : nRow
                s = ceil(5 + w*r/nCol);
                Mean = imfilter(ROI(r,:), ones(1, s)/s , 'corr', 'replicate');
                Middle = medfilt2(ROI(r,:), [1, s]);
                LT(r,:) = Mean;
                MLT(r,:) = Middle;
                
                % extend image for computing the SLT and SMLT
                half_s = ceil(s/2);
                MeanExtend = [repmat(Mean(1), [1,half_s]), Mean, repmat(Mean(end), [1,half_s])];
                MiddleExtend = [repmat(Middle(1), [1,half_s]), Middle, repmat(Middle(end), [1,half_s])];
                SLT(r,:) = MeanExtend(1:end-half_s*2)/2 + MeanExtend(1+half_s*2:end)/2;
                SMLT(r,:) = MiddleExtend(1:end-half_s*2)/2 + MiddleExtend(1+half_s*2:end)/2;
            end
            
            implot(ROI, LT, MLT, SLT, SMLT);
            maxfig;
            LT = ROI - LT;
            MMLT = medfilt2(ROI) - MLT;
            MLT = ROI - MLT;
            SLT = ROI - SLT;
            SMLT = ROI - SMLT;
            hold off;
            implot(ROI, LT, MLT, SLT, SMLT, MMLT);
            maxfig;
            
        end
        
        function Filtered = rowFilter(im, filter, ratio)
            % since the perspective effect in vehicle vision image,
            % size of rowFilter template will adjust according to the row position
            % please do roi selection first to make the horizon line first row.
            %
            % if input is a color image, then do rgb2gray
            
            % vvMarkFeature.LT
            % vvMarkFeature.MLT
            
            %preprocess
            %endpreprocess
            
            I = RawImg(im);
            I.togray();
            
            if nargin < 3
                ratio = 0.1;
            end
            
            % width = I.cols/10;% lane marking width
            
            Filtered = I.data;
            for r = 1 : I.rows
                size = ceil(5 + r*ratio);
                Filtered(r,:) = filter(I.data(r,:), size);
            end
            
        end
    end% methods
end% classdef