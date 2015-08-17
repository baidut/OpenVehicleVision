classdef BoundDetector

% I = imread('shadowy_road.jpg');
% bound = BoundDetector(I);
% mark = MarkDetector(I,bound);
% imshow(I);
% bound.plotResults;
% bound.getPoints

%% 对尺度不要求，不进行resize，resize 放在外部处理
%% 降低分辨率可以大幅提高运行速度

    %% Public properties
    properties (GetAccess = public, SetAccess = private)
        nRow, nCol
        horizon
        pointO, pointL, pointR
        lineL, lineR

        pointsL, pointsR % getPoints
        BoundL, BoundR
    end
 
    %% Public methods
    methods (Access = public)

        % =============================================================== %
        function obj = BoundDetector(I)
            [nRow, nCol, nChannel] = size(I);
            if nChannel ~= 3
                error('Color image is needed.');
            end
            % 参数初始化
            horizon = ceil(nRow/3);
            left = zeros(horizon);
            right =  repmat(nCol,1,horizon);
            theta = [-89:89];

            %% image preprocessing ====================================== %
            ROI = I( horizon:end,:,:);

            [RGB_R, RGB_G, RGB_B] = getChannel(ROI);
            RGB_min = min(min(RGB_R, RGB_G) , RGB_B);
            RGB_max = max(max(RGB_R, RGB_G) , RGB_B);
            S_modified = double(RGB_max - RGB_B) ./ double(RGB_max + 1);

            % road boundary detection =================================== %
            % 改进：左侧，右侧独立进行阈值化，防止单边的影响
            % 优点：确保两侧都检测到，处理图像左右光照不对称的情形
            % 自适应阈值改为根据均值计算，效果还是不太理想

            S_L = S_modified(:,1:floor(nCol/2));
            S_R = S_modified(:,floor(nCol/2)+1:end); % 注意不能写ceil ceil可能等于floor

            S_bw_L = S_L > 2 * mean(S_L(:)); %  0.3 0.2 % 用histeq和graythresh效果不好
            S_bw_L_imclose = imclose(S_bw_L, strel('square',3)); %imdilate imclose imopen
            S_bw_L_areaopen = bwareaopen(S_bw_L_imclose, 200); % 去除车道线

            S_bw_R = S_R > 2 * mean(S_R(:)); % 0.23 + mean(S_R(:));
            S_bw_R_imclose = imclose(S_bw_R, strel('square',3));
            S_bw_R_areaopen = bwareaopen(S_bw_R_imclose, 200);

            S_bw = [S_bw_L_areaopen, S_bw_R_areaopen];

            imdump(S_modified, S_bw,...
                S_bw_L, S_bw_L_imclose, S_bw_L_areaopen,...
                S_bw_R, S_bw_R_imclose, S_bw_R_areaopen);

            [obj.BoundL, obj.BoundR] = bw2boundaries(S_bw);
            RemovedRegion = zeros(horizon-1, nCol); % 为了正确显示直线，补上去掉的区域
            lineL = bw2line([RemovedRegion; obj.BoundL], [0:89]);
            lineR = bw2line([RemovedRegion; obj.BoundR], [-89:0]);

            try
                thetaL = lineL.theta;
                thetaR = lineR.theta;
                theta = [ceil(min(thetaL, thetaR)):floor(max(thetaL, thetaR))];
            catch ME
                error(['Sorry, no boundary is found!']);
            end

            obj.nRow = nRow;
            obj.nCol = nCol;
            obj.lineL = lineL;
            obj.lineR = lineR;
            obj.pointO = linemeetpoint( lineL.point1, lineL.point2, lineR.point1, lineR.point2 ); 
            obj.pointL = linemeetpoint( lineL.point1, lineL.point2, [1, nRow], [2, nRow]); 
            obj.pointR = linemeetpoint( lineR.point1, lineR.point2, [1, nRow], [2, nRow]);
            obj.horizon = floor(obj.pointO(2)); % Notice: 特殊图片: obj.horizon为负数 消失点在图像外
        end

        % =============================================================== %
        
        function [lineL, lineR] = getLines(obj)
            lineL = obj.lineL;
            lineR = obj.lineR;
        end

        function [pointsL, pointsR] = getPoints(obj)
            h = obj.nRow - obj.horizon + 1;
            for r = 1 : numRow
                left(r) = ceil( obj.pointO(1) - (obj.pointO(1) - obj.pointL(1))* r / h);
                right(r) = ceil( obj.pointO(1) + (obj.pointR(1) - obj.pointO(1))* r / h);
            end
        end

        function plotResults(obj)
            % 绘图 先划线
            h = obj.horizon;
            % left and right boundary line
            plotline(obj.pointO, obj.pointL,'LineWidth',3,'Color','yellow');
            plotline(obj.pointO, obj.pointR,'LineWidth',3,'Color','green');
            % obj.horizon line
            plotline([1, obj.pointO(2)], [obj.nCol, obj.pointO(2)], 'LineWidth',3,'Color','blue');
            % vanishing point
            plot(obj.pointO(1), obj.pointO(2), 'ro', 'markersize', 10);
            plot(obj.pointL(1), obj.pointL(2), 'r*');
            plot(obj.pointR(1), obj.pointR(2), 'r*');
            % feature points
            h_old = ceil(obj.nRow/3);
            for r = h_old : obj.nRow % 原来的水平线
                for c = 1 : obj.nCol
                    if 1 == obj.BoundL(r - h_old + 1, c)
                        plot(c, r, 'y+');
                    end
                    if 1 == obj.BoundR(r - h_old + 1, c)
                        plot(c, r, 'g+');
                    end
                end
            end
        end

    end% methods
end% classdef

% call bw2boundaries,bw2line