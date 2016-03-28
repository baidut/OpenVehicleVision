function results = foreach_file_do(filenames, func, varargin)
%FOREACH_FILE_DO Execure function for each specified file.
%   results = foreach_file_do(filenames, func, params)
%   results{n} = func(file{n}, varargin{:})
%
% Example
%   
%   % Display files in a folder
%   files = '%datasets/SLD2011\dataset3\sequence\01*.jpg';
%  	foreach_file_do(files,@disp);
%
%   % Get file names
%  	filename = foreach_file_do(files,@(x)x);
%   montage(filename(1:2:end));
% 
%   % Display pictures in a folder
%  	foreach_file_do(files,@imshow);
%  	
%   % Snapshot pictures.
%  	images = foreach_file_do(files,@imread);
%   montage(cat(4,images{:}));
%
% See more https://github.com/baidut/OpenVehicleVision/issues/46

% check inputs
validateattributes(filenames,{'char'},{'nonempty'});
validateattributes(func,{'function_handle'},{'nonempty'});

% gen full path
if 0 ~= exist('GetFullPath','file') % 2 or 3
    filenames = GetFullPath(filenames);
end

% get files
path = fileparts(filenames);
d = dir(fullfile(filenames));
nameFolds = {d.name}';
files = strcat([path '/'],nameFolds);

% exec function
f = @(x)func(x,varargin{:});

if nargout == 0
    cellfun(f, files, 'UniformOutput',false);
else 
    results = cellfun(f, files, 'UniformOutput',false);
end