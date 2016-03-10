% roma = RomaDataset('%dataset\roma'), % disp
% roma
% imshow(road_im.groundTruth);

classdef RomaDataset < vvDataset
    properties (Constant)
        situations = {
            'BDXD54'  				...
            'BDXN01'  				...
            'IRC04510'  			...
            'IRC041500'  			...
            'LRAlargeur13032003'	...
            'LRAlargeur14062002' 	...
            'LRAlargeur26032003' 	...
            'RD116'  				...
            'RouenN8IRC051900' 		...
            'RouenN8IRC052310' 		...
            }
        scenarioMap = containers.Map(...
            {'Original','Reference','Normal','AdverseLight','CurvedRoad'}, ...
            {'img.mov','Rimg.mov','imgnormal.mov','imgadvlight.mov', ...
            'imghighcurv.mov'} ...
            );
    end
    
    methods (Access = public)
        function roma = RomaDataset(varargin)
            roma@vvDataset(varargin{:});
            % init
            addpath(roma.path); % call loadlist
        end
        
        % 		function disp(roma)
        % 			% disp('check sub datasets...');
        % 			% ...
        % 			% disp('Database Information');
        % 			% ...
        % 		end
        
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
            files = cellfun(@getAndLoadMov,situ,scen,'UniformOutput',false);
            images = cat(1, files{:});
			
			function imageList = getAndLoadMov(situation, scenario)
				folder = fullfile(roma.path,situation);
                movFile = fullfile(folder,scenario);
                imageList = strcat(folder,filesep,roma.loadmov(movFile));
			end
        end
		
		function [time] = benchmark(roma, algo, images, threshRange)
		% images = roma.images('BDXD54','Rimg.mov');
		% roma.benchmark(@vvMark.LT, images, [1 254])
		% 
		% image = fullfile(roma.path,'BDXD54\IMG00002.jpg');
		% roma.benchmark(@vvMark.LT, image);
			if nargin < 4
				threshRange = 1:254; % exclude 0 and 255
			end
		
			if ~iscell(images), images = {images}; end
			
			% for im = images
				% image = im{1};
				% fun = @(t)algo(image,t);
				% results = arrayfun(fun, threshRange,'UniformOutput',false);
			% end
			
			imgData = cellfun(@imread,'UniformOutput',false);
			param1 = repmat(imgData,numel(threshRange));
			param2 = repmat(threshRange,numel(images));
			
			tic;
			results = cellfun(algo,param1,param2,'UniformOutput',false);
			time = toc/numel(images);
			
			% benchmark 
			% gtImgs = roma.groundTruth(images);
			
			if nargout == 0 
			% ask if visualize best results
			% ask if save results
			end
			
			
		end
		
% 		function evalResult(roma, )
% 		
% 		end
% 		
% 		function compareResult(roma, )
% 		
% 		
% 		end
		
		function benchmarkAll(roma,algo)
		% benchmark for all images, all threshold
		% and output a text file report.
		
			imgs = roma.images(roma.situations,roma.scenarioMap.values());
			benchmark(algo, images);
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
    end
    
    methods (Static)
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
		
		function gtFiles = groundTruth(oriFiles)
		% IMG00007.jpg
		% RIMG00007.pgm
			if ~iscell(oriFiles), oriFiles = {oriFiles}; end
			func = @(f) [f(1:end-12) 'R' f(end-11:end-4) '.pgm'];
			gtFiles = cellfun(func,oriFiles,'UniformOutput',false);
		end
    end
end
