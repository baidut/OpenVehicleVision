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
            % situation = roma.situations{1}; % or {roma.situations{9:end}};
            % scenario = roma.scenarioMap.values({'AdverseLight','CurvedRoad'});
            % imgs3 = roma.images(situation,scenario);
            %
            % % Display
            % figure,montage(imgs1);          % all
            % figure,montage({imgs2{1:2:end}}); % partial
            % figure,montage({imgs3{end:-1:1}});% descend
            
            if ~iscell(situation), situation = {situation}; end
            if ~iscell(scenario), scenario = {scenario}; end
            
            idx = 0;
            files = cell([1,numel(situation)*numel(scenario)]);
            
            for m = situation
                for n = scenario
                    folder = fullfile(roma.path,m{:});
                    movFile = fullfile(folder,n{:});
                    idx = idx + 1;
                    files{idx} = strcat(folder,filesep,roma.loadmov(movFile));
                end
            end
            images = cat(1, files{:});
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
