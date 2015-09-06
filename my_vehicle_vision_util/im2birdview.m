function BirdView = Img2birdview(Img, VP)

	[nRows, nCols, nChannels] = size(Img);

	if nargin < 2
		% VP = [floor(nRows/2), floor(nCols/2)];
		
		% 方案1 取中心点方式
		% movingPoints = [nCols/4, nRows*3/4; nCols*3/4, nRows*3/4; ...
		%                 1, nRows;           nCols, nRows] ;

		% 方案2 通过用户交互选择
		% h = figure;
		% Imgshow(Img);
		% maxfig;
		% [x, y] = ginput(4); % 鼠标选择4个点 需要按照顺序：左上，右上，左下，右下
		% movingPoints = [x'; y']';
		% close(h);

		
		% 方案3 可自由调整的区域，同步更新显示
		Transformed = Img;
		implot(Img, Transformed);

		selplot('Img');

		% 上左， 上右， 下右， 下左 顺序！
		movingPoints = [175,666; 825,646; 1099,1008; -598,1029];
		h = impoly(gca, movingPoints);
		roi2birdview(movingPoints);

		setColor(h,'yellow'); 
		addNewPositionCallback(h,@(p) roi2birdview(p)); % title(mat2str(p,3))

	end

	% 内部函数直接共享数据
	function roi2birdview(movingPoints)
		% title(mat2str(movingPoints,3));return

		% 改为上左， 上右， 下右， 下左 顺序！原来是 上左 上右 下左 下右
		fixedPoints =  [1, 1;               nCols, 1;...
		                nCols, nRows;       1, nRows];
		% fixedPoints =  [1, 1;               20, 1;...
		%                 1, 20;              20, 20] ;

		tform = fitgeotrans(movingPoints, fixedPoints, 'projective');
		BirdView = imwarp(Img, tform, 'OutputView', imref2d([nRows, nCols]));
		subplot(1,2,2); %selplot('Transformed');
		imshow(BirdView);
	end
end

% 图像统一命名为Img或IM 命名为I和im不方便替换 容易覆盖imshow showImg等
% impoly imploy

