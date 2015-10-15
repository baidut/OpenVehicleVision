%% An Illumination-Robust Approach for Feature-Based Road Detection
% (Zhenqiang Ying, Ge Li & Guozhen Tan) to appear in IEEE-ISM2015
% (IEEE International Symposium on Multimedia 2015) conference.
%
% Email: yinzhenqiang # gmail.com
% Website: https://github.com/baidut/openvehiclevision

global dumpLevel;
global saveEps;
global dumpPath;

mkdir('results');
dumpPath = '.\results';
dumpLevel = 1;
saveEps = false;

path =  'F:\Documents\MATLAB\dataset\roma\';
ext = 'jpg';

roma = { str2files([path 'BDXD54\*.' ext]), ...
		 str2files([path 'BDXN01\*.' ext]), ...
		 str2files([path 'IRC04510\*.' ext]), ...
		 str2files([path 'IRC041500\*.' ext]), ...
		 str2files([path 'LRAlargeur13032003\*.' ext]), ...
		 str2files([path 'LRAlargeur14062002\*.' ext]), ...
		 str2files([path 'LRAlargeur26032003\*.' ext]), ...
		 str2files([path 'RD116\*.' ext]), ...
		 str2files([path 'RouenN8IRC051900\*.' ext]), ...
		 str2files([path 'RouenN8IRC052310\*.' ext]), ...
        };

% Test on : roma{2}, roma{end} [roma{2:3}] [roma{:}]
% figs = foreach_file_do([roma{2:3}], @roadDetection); 
% imdump(1, figs{:});

files = [roma{:}];

for ii = 1 : length(files)
	fig = roadDetection(files{ii});
    imdump(1, fig);
    close(fig);
end

%% generate 'evaluation.tex' for buiding pdf of evaluation results.
text = evalc('gentex');
fid = fopen('results/evaluation.tex','w');
fprintf(fid, '%s', text);
fclose(fid);