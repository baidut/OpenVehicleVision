function [eval, time] = compare_ii_road_area_detection

% since different situations are captured by different cameras,
% the params of ii image is different.
                  %1   2   3   4   5   6   7   8   9   10
iiParamList = 255*[0.2,.10,.06,.06,.05,.05,.05,.13,.07,.04];
iiParamList = num2cell(iiParamList,1); % to cell array
[eval, time] = benchmark_on_roma(@road_detection_via_ii, iiParamList);


disp ok
end

%% Invariant Image
% GetInvariantImage(inputImage,40.3274,0,1);
%  1   2   3   4   5   6   7   8   9   10
% [ 66, 79, 40, 40, 39, 39, 61,108, 76, 80];
%% ii image
% [.69,.52,.42,.42,.43,.43,.66,.90,.81,.83];

%  iiParamList(iSitu)
function [eval, time] = benchmark_on_roma(algo, paramList)
%Benchmark on Roma Dataset
% Benchmark single algo in multi situation
% paramList is a cell array

roma = RomaDataset('%datasets\roma');
n = numel(roma.situations);
time = zeros([n 1]);
eval = repmat(ConfMat(),[n 1]);

for iSitu = 1:n
    rows = strcmp(roma.data.situation,roma.situations{iSitu}) == 1;
    rawImgFile = roma.data(rows,:).filename;
    
    gtImgFile = roma.roadAreaGt(rawImgFile{:});
    param = paramList(iSitu);
    
    f = @(im)algo(im,param{:});
    [eval(iSitu), time(iSitu)] = benchmark1Algo1Situ(rawImgFile, gtImgFile, f, char(algo));
end

end

function [eval, time] = benchmark1Algo1Situ(rawImgFile, gtImgFile, algo, algoname)
%Benchmark single algo in single situation
% Note we just benchmark the lower half of image.

rawImg = cellfun(@imread,rawImgFile,'UniformOutput',false);
gtImg = cellfun(@imread,gtImgFile,'UniformOutput',false);

roiOf = @(x)x(ceil(end/2):end,:,:);
roiImg = cellfun(roiOf,rawImg,'UniformOutput',false);
gt = cellfun(roiOf,gtImg,'UniformOutput',false);

tic
result = cellfun(algo,roiImg,'UniformOutput',false);
time = toc/numel(roiImg);

eval = ConfMat(result,gt);
% disp(eval);
% vis(eval,roiImg);
maskedImg = vis(eval, roiImg);

rename = @(f) [f(1:end-4) '_', algoname, '.png'];
maskedImgFile = cellfun(rename,rawImgFile,'UniformOutput',false);

cellfun(@imwrite,maskedImg,maskedImgFile,'UniformOutput',false);
% save visualization images

end