% roma = RomaDataset('%datasets\roma'), % disp
% roma
% imshow(road_im.groundTruth);

classdef RomaDataset < vvDataset
    properties (Constant)
        situations = {
            'BDXD54'  				... %1
            'BDXN01'  				... %2
            'IRC04510'  			... %3
            'IRC041500'  			... %4
            'LRAlargeur13032003'	... %5
            'LRAlargeur14062002' 	... %6
            'LRAlargeur26032003' 	... %7
            'RD116'  				... %8
            'RouenN8IRC051900' 		... %9
            'RouenN8IRC052310' 		... %10
            }
        scenarioMap = containers.Map(...
            {'Original','Reference','Normal','AdverseLight','CurvedRoad'}, ...
            {'img.mov','Rimg.mov','imgnormal.mov','imgadvlight.mov', ...
            'imghighcurv.mov'} ...
            );
        
        
    end
    properties
        data
        %{
            rows = strcmp(roma.data.scenario,'AdverseLight') == 1;
            adverseLightCases = roma.data(rows,:);
            adverseLightFiles = adverseLightCases.filename;
        %}
    end
    
    methods (Access = public)
        function roma = RomaDataset(varargin)
            roma@vvDataset(varargin{:});
            % init
            addpath(roma.path); % call loadlist
            
            filename = {};
            situation = {};
            scenario = {};
            
            sit = roma.situations;
            sceKey = {'Normal','AdverseLight','CurvedRoad'};
            sceVal = roma.scenarioMap.values(sceKey);
            
            
            for iSit = 1:numel(sit)
                for jSce = 1:numel(sceVal)
                    f = roma.loadMov(sit{iSit},sceVal{jSce}); % column vector
                    n = numel(f);
                    filename = [filename; f(:)];%filename = {filename{:}, f{:}};
                    situation = [situation; repmat(sit(iSit), [n 1])];
                    scenario = [scenario; repmat(sceKey(jSce), [n 1])];
                end
            end
            
            roma.data = table(filename, situation, scenario);
            %             disp(roma.data);
        end
        
        % 		function disp(roma)
        % 			% disp('check sub datasets...');
        % 			% ...
        % 			% disp('Database Information');
        % 			% ...
        % 		end
        function varargout = scenarios(roma, n)
            % roma.situations(1)
            % roma.situations(1:3)
            val = roma.scenarioMap.values();
            varargout = val{n};
        end
        
        function images = images(roma, situation, scenario)
            % roma = RomaDataset('%datasets\roma');
            % % Basic usage:
            % imgs1 = roma.images('BDXD54','Rimg.mov');
            % imgs2 = roma.images({'BDXD54','BDXN01'},{'imgadvlight.mov','imghighcurv.mov'});
            %
            % % Advanced usage:
            % situation = roma.situations(1:2); % or {roma.situations(9:end)};
            % scenario = roma.scenarioMap.values({'AdverseLight','CurvedRoad'});
            % imgs3 = roma.images(situation,scenario);
            %
            % % Display
            % figure,montage(imgs1);          % all
            % figure,montage(imgs2(1:2:end)); % partial
            % figure,montage(imgs3(end:-1:1));% descend
            %
            % % Get all images
            % imgs = roma.images(roma.situations,roma.scenarioMap.values());
            
            if ~iscell(situation), situation = {situation}; end
            if ~iscell(scenario), scenario = {scenario}; end
            
            situ = repmat(situation, [1 numel(scenario)]);
            scen = repmat(scenario, [1 numel(situation)]);
            files = cellfun(@roma.loadMov,situ,scen,'UniformOutput',false);
            images = cat(1, files{:});
        end
        
        function imageList = loadMov(roma, situation, scenario)
            folder = fullfile(roma.path,situation);
            movFile = fullfile(folder,scenario);
            imageList = strcat(folder,filesep,roma.loadmov(movFile));
        end
    end
    
    methods (Static)
        function [eval, time] = eval_road(algos, situations)
            % road detection evaluation on ROMA
            % Benchmark single algo in multi situation
            
            % PRAM      | TYPE   | USE CASE | DEFAULT VALUE
            % algo       struct or struct array
            % .name      char
            % .func      function_handle
            % .param     1X10 cell
            % situations array      1:2,2      1:10
            
            disp('load algo...');
            if ~isfield(algos, 'func')
                error('func is needed!');
            end
            if ~isfield(algos, 'name')
                if isempty(inputname(1)) % algoArr(2)
                    for algo = algos
                        algo.name = char(algo.func);
                    end
                else
                    if numel(algos) > 1
                        names = num2str([1:numel(algos)]', [inputname(1) '%0d']);
                        for n = 1:numel(algos)
                            algos(n).name = names(n);
                        end
                    else
                        algos.name = inputname(1);
                    end
                end
            end
            if ~isfield(algos, 'param')
                for algo = algos
                	algo.param = cell(numel(RomaDataset.situations), 1); % empty
                end
            end
            disp(algos);
            
            disp('load situations...');
            roma = RomaDataset('%datasets\roma');
            n = numel(roma.situations);
            
            if nargin < 2
                % test all situations
                situations = 1:n;
            end
            
            time = zeros([n 1]);
            eval = repmat(ConfMat(),[n 1]);
            
            for algo = algos
                for iSitu = situations % 1:n
                    disp(roma.data.situation);
                    
                    rows = strcmp(roma.data.situation,roma.situations{iSitu}) == 1;
                    rawImgFile = roma.data(rows,:).filename;
                    
                    gtImgFile = roma.roadAreaGt(rawImgFile{:});
                    param = algo.param(iSitu);
                    
                    f = @(im)algo(im,param{:});
                    [eval(iSitu), time(iSitu)] = ConfMat.eval(rawImgFile, gtImgFile, f, algoname);
                end
            end
        end
        
        function [] = eval_road_bound()
            % TODO: extract curve via GT
            % then evaluate it
        end
        
        function [TPs,FPs,TNs,FNs, time] = benchmark(algo, imageFiles, threshRange)
            % images = roma.images('BDXD54','Rimg.mov');
            % roma.benchmark(@vvMark.LT, images, [1 254])
            %
            % image = fullfile(roma.path,'BDXD54\IMG00002.jpg');
            % roma.benchmark(@vvMark.LT, image);
            if nargin < 4
                threshRange = 1:254; % exclude 0 and 255
            end
            
            if ~iscell(imageFiles), imageFiles = {imageFiles}; end
            
            % for im = images
            % image = im{1};
            % fun = @(t)algo(image,t);
            % results = arrayfun(fun, threshRange,'UniformOutput',false);
            % end
            
            images = cellfun(@imread,imageFiles,'UniformOutput',false);
            gtImgs = cellfun(@imread,RomaDataset.groundTruth(imageFiles{:}),'UniformOutput',false);
            
            param1 = repmat(images,numel(threshRange));
            param2 = repmat(threshRange,numel(images));
            
            tic;
            results = cellfun(algo,param1,param2,'UniformOutput',false);
            time = toc/numel(imageFiles);
            
            % benchmark
            [TPs,FPs,TNs,FNs] = RomaDataset.compareWithGroundTruth(results, gtImgs);
            
            if nargout == 0
                % ask if visualize best results
                % ask if save results
            end
        end
        
        function [TPs,FPs,TNs,FNs,cMask] = compareWithGroundTruth(results, GTs)
            % roma = RomaDataset('%datasets\roma');
            % imageFile = fullfile(roma.path, 'RouenN8IRC051900\IMG00007.jpg');
            % I = imread(imageFile);
            % GT = imread(roma.groundTruth(imageFile));
            % Result = vvMark.F_LT(I, 30); % threshold:30
            % [TP,FP,TN,FN,visualizeMask] = roma.compareWithGroundTruth(Result, GT);
            % imshow(I+visualizeMask);
            
            if ~iscell(results), results = {results}; end
            [cTP,cFP,cTN,cFN,cMask] = cellfun(@eval,results,GTs,'UniformOutput',false);
            TPs = cell2mat(cTP);
            FPs = cell2mat(cFP);
            TNs = cell2mat(cTN);
            FNs = cell2mat(cFN);
            
            function [TP,FP,TN,FN,visualizeMask] = eval(result, GT)
                % lane-marking    GT == 255   result == 1
                % special-marking GT == 125   result == 0
                % non-marking     GT == 0     result == 0
                [TP,FP,TN,FN,visualizeMask] = vvDataset.evalDetector(result, GT==255, 1);
            end
        end
        %
        function [TPs,FPs,TNs,FNs] = compareTwo(results1, results2)
            assert(numel(results1)==numel(results2));
            if ~iscell(results1),
                results1 = {results1};
            end
            
            GT = roma.groundTruth(results1);
            [cTP,cFP,cTN,cFN] = cellfun(@eval,results,GT);
            TPs = cell2mat(cTP);
            FPs = cell2mat(cFP);
            TNs = cell2mat(cTN);
            FNs = cell2mat(cFN);
            
            function [TP,FP,TN,FN] = eval(result, gt)
                % Note TP... is not a ratio but a count number about
                % how many true positive pixels in image or images.
                
                % lane-marking    gt == 255   result == 1
                % special-marking gt == 125   result == 0
                % non-marking     gt == 0     result == 0
                TP_bw = (result == 1) & (gt == 255);
                FP_bw = (result == 1) & (gt ~= 255);
                TN_bw = (result == 0) & (gt ~= 255);
                FN_bw = (result == 0) & (gt == 255);
                
                TP = sum(TP_bw(:));
                FP = sum(FP_bw(:));
                TN = sum(TN_bw(:));
                FN = sum(FN_bw(:));
            end
        end
        
        function benchmarkAll(algo)
            % benchmark for all images, all threshold
            % and output a text file report.
            images = RomaDataset.images(RomaDataset.situations,RomaDataset.scenarioMap.values());
            benchmark(algo, images);
            % output a text file report
        end
        
        function comparePerformance(roma,algoList)
            
            % See also kitti road benchmark http://www.cvlibs.net/datasets/kitti/eval_road.php
            algoName = cellfun(@char, algoList, 'UniformOutput', false);
            cellfun(@roma.benchmarkAll, algoList, 'UniformOutput', false);
            
            % KITTI: MaxF,AP,PRE,REC,TN,FN,FPR,FNR,Runtime,Environment
            % MaxF
            % AP
            ACC = (TP + TN) / (TP + TN + FP + FN); % Accuracy (ACC)
            PRE = TP / (TP + FP); % Precision
            REC = TP / (TP + FN); % Recall
            FPR = FP / (FP + TN); % fall-out or false positive rate (FPR)
            FNR = FN / (FN + TP); % miss rate or false negative rate (FNR)
            % Runtime = time ./ n_images;
            % to check your environment, run `msinfo32` in windows
            Environment = repmat('4 cores @ 3.4 Ghz (Matlab)', [1 n_algo]);
            
            % output text file report
            T = table(ACC,PRE,REC,TN,FN,FPR,FNR,Environment, ...
                'RowNames',algoName);
            %
            % plot ROC and DSC curve for each algo
        end
        
        function files = loadmov(movFile)
            %RomaDataset.loadlist output full file name
            %loadlist provided by roma will lose ext.
            data=textread(movFile,'%s','delimiter','\n','whitespace','');
            
            % first line of the file contains a header
            % the number of elements
            nelem = str2double(char(data(1)));
            % all the names
            files=data(2:nelem+1);
        end
        
        function gtFiles = groundTruth(varargin)
            % % USAGE:
            %    RomaDataset.groundTruth('IMG00007.jpg')
            %    RomaDataset.groundTruth(imageFiles{:})
            
            % IMG00007.jpg
            % RIMG00007.pgm
            func = @(f) [f(1:end-12) 'R' f(end-11:end-4) '.pgm'];
            gtFiles = cellfun(func,varargin,'UniformOutput',false);
        end
        
        function gtFiles = roadAreaGt(varargin)
            func = @(f) [f(1:end-4) '.png'];
            gtFiles = cellfun(func,varargin,'UniformOutput',false)';
            % N*1 cell
            if numel(gtFiles) == 1, gtFiles = gtFiles{1}; end
        end
    end
end
