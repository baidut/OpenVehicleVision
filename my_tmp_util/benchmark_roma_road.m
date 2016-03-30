function [ output_args ] = benchmark_roma_road( algos )
%BENCHMARK_ROMA_ROAD Test the performance of road area detection on Roma
%dataset
%   Detailed explanation goes here
    for n = 1:numel(algos)
       algo = algos{n};
       % tic
       
    end
    
    if numel(algos) == 1
        roma = RomaDataset('%datasets\roma');
        imageFile = fullfile(roma.path, 'RouenN8IRC051900\IMG00007.jpg');
        I = imread(imageFile);
        GT = imread(roma.roadAreaGt(imageFile));

        Result = algos(I); % 
        [TP,FP,TN,FN,visualizeMask] = roma.compareWithGroundTruth(Result, GT);
        imshow(I+visualizeMask);
    end

end

% view roma road ground truth - see show_dataset





