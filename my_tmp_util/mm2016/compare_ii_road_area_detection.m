function [eval, time] = compare_ii_road_area_detection

%% compare the results of diff rgb2ii methods
extend = '_felzen';% add light constraint
% extend = '_histotsu';

algonames = {'rgb2ii_2d', ...
             'will2014', ...
             'GetInvariantImage01', ...
};
algonames = strcat(algonames, extend);

ii_methods = {@rgb2ii_2d,... % dualLaneDetector.rgb2ii_ori
              @rgb2ii.will2014,...
              @(im,p)GetInvariantImage(im,p,0,1),...
}; 

% since different situations are captured by different cameras,
% the params of ii image is different.
% --------------------- 1   2   3   4   5   6   7   8   9   10 ------------
ii_params = {num2cell([0.2,.10,.10,.06,.05,.05,.05,.13,.07,.07],1),...
             num2cell([.69,.52,.42,.42,.43,.43,.66,.90,.81,.83],1),...
             num2cell([ 66, 79, 40, 40, 39, 39, 61,108, 76, 80],1),...
};

N = numel(ii_methods);
time = cell([N 1]);
eval = cell([N 1]);

for n = 1:N % 1
    ii_method = ii_methods{n};
    ii_param = ii_params{n};
    [eval{n}, time{n}] = benchmark_on_roma(@(im,p)road_detection_via_ii(im,ii_method,{p}), ii_param, algonames{n});
%     [eval{n}, time{n}] = benchmark_on_roma(@(im,p)road_detection_via_ii(im,ii_method,{p}), ii_param, algonames{n});
    % save
end

%% Save result to mat
% ours.eval = eval{1};
% ours.time = time{1};
% will2014.eval = eval{2};
% will2014.time = time{2};
% GetInvariantImage01.eval = eval{3};
% GetInvariantImage01.time = time{3};
% save('%mat/ii_result.mat', 'ours', 'will2014', 'GetInvariantImage01');

ours.eval = eval{1};
ours.time = time{1};
will2014.eval = eval{2};
will2014.time = time{2};
GetInvariantImage01.eval = eval{3};
GetInvariantImage01.time = time{3};
save(['%mat/ii_result' extend '.mat'], 'ours', 'will2014', 'GetInvariantImage01');

% eval{1}.roc('r*');eval{2}.roc('g*');eval{3}.roc('b*');
% hold on;plot(time{1},'r');plot(time{2},'g');plot(time{3},'b')

end

%% Clean
%{

for n = 1:numel(RomaDataset.situations)
    foreach_file_do(['%datasets/roma/', RomaDataset.situations{n}, '/*@*.png'], @delete);
end
%}


% function [eval, time] = benchmark_on_roma(algo, paramList, algoname)
% this function has been moved to RomaDataset class
% end

% function [eval, time] = benchmark1Algo1Situ(rawImgFile, gtImgFile, algo, algoname)
% this function has been moved to ConfMat class
% end


