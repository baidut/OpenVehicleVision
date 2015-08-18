classdef MarkDetector

% mark = MarkDetector(I,bound);

    %% Public properties
    properties (GetAccess = public, SetAccess = private)
    	roadBirdView
    	nRow, nCol
    	Bound
    	OriIm
    end
 
    %% Public methods
    methods (Access = public)

        % =============================================================== %
        function obj = MarkDetector(I, Bound)
        	obj.Bound = Bound;
        	obj.OriIm = I;
			image = rgb2gray(I);
			[obj.nRow, obj.nCol, nChannel] = size(I);
			pointLU = Bound.pointO/2 + Bound.pointL/2;
			pointRU = Bound.pointO/2 + Bound.pointR/2;
			% 显示特征点
			% figure;subplot(1,2,1);imshow(I);hold on;
			% plot(pointLU(1), pointLU(2), 'yo', 'markersize', 10);
			% plot(pointRU(1), pointRU(2), 'bo', 'markersize', 10);
			% plot(pointL(1), pointL(2), 'y*', 'markersize', 10);
			% plot(pointR(1), pointR(2), 'b*', 'markersize', 10);
			B = [ pointLU; pointRU;  Bound.pointL; Bound.pointR];% 源图像中的点的坐标矩阵为： 点在图像外
			outCols = 80; outRows = 60;
			A = [1, 1;outCols,1;1,outRows;outCols, outRows];
			tform = fitgeotrans(B, A, 'projective');
			obj.roadBirdView = imwarp(I,tform, 'OutputView', imref2d([outRows, outCols]));
        end

        % =============================================================== %
        function ratio = plotLane(obj)
        	% 还原到原图很简单，知道了列的位置，得到占整个列的百分比，
			% 再对原来的各行找该位置即可进行验证标定工作

			% 需要先进行DLD滤波 采用带掩码的滤波器
			% mask = ( RoadRegion ~= 0 ); % 没作用 待解决mask_dilate腐蚀一下mask
			H = [-1, 0, 1, 0, -1;
			     -1, 0, 2, 0, -1;
			     -1, 0, 2, 0, -1;
			     -1, 0, 2, 0, -1;
			     -1, 0, 1, 0, -1];
			% 足够长的模板匹配效果较好 5 个像素长度

			% 效果较好
			% H = [-1, 0, 1, 0, -1;
			%      -2, 0, 4, 0, -2;
			%      -1, 0, 1, 0, -1];
			% RoadFiltered = roifilt2(H,RoadRegion,mask);
			% imfilter默认边界为0处理
			RoadFiltered = imfilter(obj.roadBirdView,H,'replicate'); % & mask
			BW = im2bw( RoadFiltered, graythresh(RoadFiltered) );
			% 去除非四邻居连通域
			Markings = bwareaopen(BW,18,4);
			% 只检测中心的车道标记线？

			% 统计每一列的和值
			A = sum(Markings, 1);
			[maxValue index] = max(A);
			ratio = index / 80, % 占的比例 outCols
			implot(BW, Markings);
			% 验证区域，还原车道标记位置到图像中
		end

		function [pointsM, labeled] = drawLine(obj, ratio)
			% 注意需要先plotlane
			[pointsL, pointsR]  = obj.Bound.getPoints(); % Bound.horizon : Bound.nRow
			labeled = obj.OriIm;
			figure;
			imshow(labeled); hold on;
			h = obj.Bound.nRow - obj.Bound.horizon + 1;
			for r = 1 : h
				pointsM(r) = ceil( pointsL(r) + ratio* (pointsR(r) - pointsL(r)) );
				row = r+obj.Bound.horizon;
				plot(pointsM(r), row, 'ro');
				plot(pointsL(r), row, 'g+');
				plot(pointsR(r), row, 'b+');
				labeled(row, pointsM(r));
			end
		end

    end% methods
end% classdef

% call bw2boundaries,bw2line