% This code 

function test_roma(imgFile)

if nargin < 1
    % imgFile = '%datasets\roma\BDXD54\IMG00002.jpg';
    imgFile = '%datasets\roma\RouenN8IRC052310\IMG01339.jpg';
end

%% Lane marking filters
% <row> - an image row
% <s> - pixel size of lane-marking

% Note:
% 1. since no image padding done in SMLT and SLT,
% the left <s> and right <s> pixel will be kept no change.
% 2. since the threshold is given in the paper,
% the original methods outputs a BW lane-marking image.
% Differently, here we outputs a lane-marking-filtered image.
%
% Todo:
% other existing methods: PLT
% other idea: superpixel based SMLT


% % bw lane-marking extractors
% %
% % <t> 		- threshold
% % <LT> 		- local mean extractor
% % <MLTF> 	- local median extractor
%
% LT 	= @(row, s, t) (row > t + LTF(row, s));
% MLT 	= @(row, s, t) (row > t + MLTF(row, s));

%% Adaptive threshold version of LT,MLT...

Raw = imread(imgFile);
ROI = Raw(ceil(end/2):end,:,1); % R component
% MarkPoints = vvMark.F_MLT(ROI);

f = {@vvMark.F_LT,@vvMark.F_MLT,@vvMark.F_SLT,@vvMark.F_SMLT};
for n = 1:numel(f);
    subplot(2,2,n);
    imshow(f{n}(ROI));title(char(f{n}),'Interpreter','none');
end
% Elapsed time is 3.359061 seconds.

% Fig.subimshow(Raw, MarkPoints);

% Conclusion
% LT
% = edge        if s <= lane-marking;
% = all region  if s > 2*lane-marking;