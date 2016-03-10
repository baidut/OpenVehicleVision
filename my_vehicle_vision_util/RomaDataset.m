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
            
            % % test runtime
            % tic, imgs = roma.images(roma.situations,roma.scenarioMap.values()); toc
            % forloop version | - | cellfun version | 0.147112 s
            % tic, imgs = roma.images(roma.situations(2:3),roma.scenarioMap.values({'AdverseLight','CurvedRoad'})); toc
            % forloop version | 0.014138 s | cellfun version | 0.014667 s
            % tic, imgs = roma.images('BDXD54','Rimg.mov'); toc
            % forloop version | 0.007714 s | cellfun version | 0.009108 s
            
            if ~iscell(situation), situation = {situation}; end
            if ~iscell(scenario), scenario = {scenario}; end
            
			% for-loop version \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
			%{
            idx = 0;
            files = cell([1,numel(situation)*numel(scenario)]);
            
            for m = situation
                for n = scenario
                    folder = fullfile(roma.path,m{1}); % m{1} is faster than m{:}
                    movFile = fullfile(folder,n{1});
                    idx = idx + 1;
                    files{idx} = strcat(folder,filesep,roma.loadmov(movFile));
                end
            end
			
			images = cat(1, files{:}); % buggy when one of files is empty: Dimensions of matrices being concatenated are not consistent.
			%}
			% end for-loop version ///////////////////////////////////
			
			% cellfun version \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
            %%{
			situ = repmat(situation, [1 numel(scenario)]);
			scen = repmat(scenario, [1 numel(situation)]);
            files = cellfun(@getAndLoadMov,situ,scen,'UniformOutput',false);
            images = cat(1, files{:});
            % images{1}
			
			function imageList = getAndLoadMov(situation, scenario)
				folder = fullfile(roma.path,situation);
                movFile = fullfile(folder,scenario);
                imageList = strcat(folder,filesep,roma.loadmov(movFile));
			end
            %%}
			% end cell version ///////////////////////////////////////
        end
		
		function benchmark(algo, images, threshRange)
			tic;
			% cellfun(@algo, images, )
			time = toc;
		end
		
		function benchmarkAll(roma,algo)
		% benchmark for all images, all threshold
		% and output a text file report.
		
			for m = roma.situations{:}
                for n = roma.scenarioMap.values
					files = roma.images(m,n);
					benchmark(algo, images, 1:254); % (exclude 0 and 255)
                end
            end
		
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
    end
end
