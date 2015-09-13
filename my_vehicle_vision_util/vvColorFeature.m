function FeatureMap = vvColorFeature(I, feature)
%VVCOLORFEATURE
% USAGE:
% I = imread('IMG00071_ll_s_paper_ISM2015.jpg'); VVCOLORFEATURE(I);
[nRow, nCol, nChannel] = size(I);

if nChannel ~= 3
	error('Input image must have 3 color channels.');
end

[RGB_R, RGB_G, RGB_B] = getChannel(I);
RGB_min = min(min(RGB_R, RGB_G) , RGB_B);
RGB_max = max(max(RGB_R, RGB_G) , RGB_B);

if nargin < 2 % display test when no feature is specified.

    S = double(RGB_max - RGB_min) ./ double(RGB_max + 1);
    S2 = double(RGB_max - RGB_B) ./ double(RGB_max + 1);

    Redness = histeq(RGB_R - max(RGB_G, RGB_B));
    % Greeness = mat2gray( RGB_G - max(RGB_R, RGB_B) );
    Greeness = double(RGB_G) - double(max(RGB_R, RGB_B));
    Greeness = histeq(Greeness);
    Blueness = histeq(RGB_B - max(RGB_R, RGB_G));

    test = cat(3, RGB_R, RGB_G, 255 - RGB_B);
    test1 = cat(3, 255-RGB_R, 255-RGB_G, 255-RGB_B);
    test2 = cat(3, RGB_R, RGB_G, RGB_R);
    test3 = cat(3, RGB_R, RGB_G, RGB_G);

    implot(I, S, S2, ...
    	Redness, Greeness, Blueness, ...
    	test, test1, test2, test3);

	return;
end

switch feature
case 'S2'
	FeatureMap = double(RGB_max - RGB_B) ./ double(RGB_max + 1);
end

% negative number -> zero for unsigned class.
% >> A = [1 2 4; 5 6 9];
% >> A - 6

% ans =

%     -5    -4    -2
%     -1     0     3

% >> whos A
%   Name      Size            Bytes  Class     Attributes

%   A         2x3                48  double              

% >> B = uint8(A);
% >> B - 6

% ans =

%     0    0    0
%     0    0    3