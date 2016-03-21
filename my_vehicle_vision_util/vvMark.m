classdef vvMark < handle
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
    
    properties (Constant)
        % [Sm,SM] = [5cm,20cm].
        % s_min = 17;  % 5cm = 17.5 pixel
        % s_max = 70;  % 20cm = 70 pixel % 58 pixel
        
        k_min = 5;      % min kernel size
        k_max = 2*70;
        T_good = 35;    %25 is too low, fixed threshold, not the best threshold but works well
    end

    
    methods (Access = public)
        function md = vvMark(s_range, horizon, thresh)
        % md: Mark detector
            md.s_min = s_range(1);
            md.s_max = s_range(2);
            md.thresh = thresh;
            md.horizon = horizon;
        end
        
        function res = LT(md, im)
            % speedup: when size not change, the rows can do filtering
            % together
            % block-based filtering
            m_im = vvMark.aver(im, @md.LT, md.size);
            res = (im - m_im) > T;
        end
        

    end
    
    %%
    methods (Static)
        
        
        
        %         function res = PLT(im, s)
        %         end
        
        %         function res = SLT(im, s)
        %             half_s = ceil(s/2);
        %             Middle = imfilter(im, ones(1, s)/s , 'corr', 'replicate');
        %             Middle = [repmat(Middle(1), [1,half_s]), Middle, repmat(Middle(end), [1,half_s])];
        %             res = Middle(1:end-half_s*2)/2 + Middle(1+half_s*2:end)/2;
        %         end
        %         function res = SMLT(im, s)
        %             half_s = ceil(s/2);
        %             Middle = medfilt2(im, [1, s]);
        %             Middle = [repmat(Middle(1), [1,half_s]), Middle, repmat(Middle(end), [1,half_s])];
        %             res = Middle(1:end-half_s*2)/2 + Middle(1+half_s*2:end)/2;
        %         end
        
        function res = DLD(im, s) % -1-1 1 1 1 1 -1 -1
            I = double(I); % negative numbers
            half_s = ceil(s/2);
            template_DLD = ones(1, s*2);
            template_DLD(1:half_s) = -1;
            template_DLD(half_s*3:s*2) = -1;
            res = imfilter(im, template_DLD, 'corr', 'replicate');
        end
        
        function m_im = aver(im, func, s)
            if nargin < 3
                s = [vvMark.k_min vvMark.k_max];
            end
            m_im = zeros(size(im), 'like', im);
            ratio = (s(2) - s(1)) / size(im, 1);
            
            for r = 1 : size(im,1)
                m_im(r,:) = func(im(r,:), ceil(s(1) + r*ratio));
            end
        end
        
        function res = F_LT(im, T, varargin)
            if nargin < 2
                T = vvMark.T_good;
            end
            % speedup: when size not change, the rows can do filtering
            % together
            % block-based filtering
            m_im = vvMark.aver(im, @vvMark.LT, varargin{:});
            res = (im - m_im) > T;
        end
        
        function res = F_MLT(im, T, varargin)
            % can deal with RGB image
            if nargin < 2
                T = vvMark.T_good;
            end
            m_im = vvMark.aver(im, @vvMark.MLT, varargin{:});
            res = (im - m_im) > T;
        end
        
        function res = symmetrical(im, func, T, s)
            % solved: column 1:s_max and end-s_max:s_max will not be assigned value
            if nargin < 4
                s = [vvMark.k_min vvMark.k_max];
            end
            s_max = s(2);
            
            m_im = vvMark.aver(im, func, s);
            m_im_left = [m_im(:,1:end-s_max) im()];
            m_im_right = [m_im(:,1+s_max:end) ];
            
            res = false(size(im));
            res(:,1+s_max:end-s_max) = (im - m_im_left) > T & (im - m_im_right) > T;
        end
        
        function res = F_SMLT(im, T, varargin)
            if nargin < 2
                T = vvMark.T_good;
            end
            res = vvMark.symmetrical(im, @vvMark.MLT, T, varargin{:});
        end
        
        function res = F_SLT(im, T, varargin)
            if nargin < 2
                T = vvMark.T_good;
            end
            res = vvMark.symmetrical(im, @vvMark.LT, T, varargin{:});
        end
        % matlab speed measure:
        % pixel level for-loop
        % row level for-loop
        % block level for-loop
        % arrayfun
        % left and right
        % gpu
        
        %% fix-ratio-threshold methods
        % TODO
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
                Filtered(r,:) = filter(I.data(r,:), ceil(5 + r*ratio));
            end
            
        end
    end% methods
end% classdef