function BirdView = im2birdview(im, VP)

[nRows, nCols, nChannels] = size(im);

if nargin < 2
	% VP = [floor(nRows/2), floor(nCols/2)];
	
	% 方案1 取中心点方式
	% movingPoints = [nCols/4, nRows*3/4; nCols*3/4, nRows*3/4; ...
	%                 1, nRows;           nCols, nRows] ;

	% 方案2 通过用户交互选择
	h = figure;
	imshow(im);
	maxfig;
	[x, y] = ginput(4); % 鼠标选择4个点 需要按照顺序：左上，右上，左下，右下
	movingPoints = [x'; y']';
	close(h);

	% 可自由调整的区域，同步更新显示

	fixedPoints =  [1, 1;               nCols, 1;...
	                1, nRows;           nCols, nRows] ;
	% fixedPoints =  [1, 1;               20, 1;...
	%                 1, 20;              20, 20] ;

	tform = fitgeotrans(movingPoints, fixedPoints, 'projective');
	BirdView = imwarp(im, tform, 'OutputView', imref2d([nRows, nCols]));
end