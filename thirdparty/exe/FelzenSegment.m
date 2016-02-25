function ISeg = FelzenSegment(Img, sigma, k, min)
% http://cs.brown.edu/~pff/segment/
% usage: %s sigma k min input(ppm) output(ppm)
% sigma = 0.5, K = 500, min = 50.
% sigma = 0.5, K = 1000, min = 100.
	if nargin < 4, min = 50;
		if nargin < 3, k = 500;
			if nargin < 2, sigma = 0.5;
			end
		end
	end
	
	imwrite(Img,'%temp.ppm');
    % put the exe at system path
	cmdstr = sprintf('FelzenSegment.exe %%temp.ppm %f %d %d',sigma,k,min);
	[status,cmdout] = dos(cmdstr);
    disp(cmdout);
	if status == 0 %successfully
		ISeg = imread('%tempo.ppm');
	else
		error('Fail in calling FelzenSegment.exe');
	end
% status = system('dir')
% str = evalc('system(''dir'')')
% [status,cmdout] = dos('dir');
% http://blogs.mathworks.com/community/2010/05/17/calling-shell-commands-from-matlab/

% Raw = imread('F:\Documents\pku-road-dataset\1\EMER0009\0379.jpg');
% Seg = mexFelzenSegmentIndex(Raw, 0.5, 500, 50);
% J = mexFelzenSegmentIndex(Raw, sigma, c, minSize)

% Invalid MEX-file  The specified module could not be found.
end