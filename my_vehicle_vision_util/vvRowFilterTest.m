function vvRowFilterTest(I, h, w)
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