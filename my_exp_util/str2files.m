function fileList = str2files(string)
% STR2FILES parse a string which specifies some files,
% then output the name(includes path) of corresponding files into a cellstr
% USAGE:
% 	str2files('pictures/2.jpg') % one image 1X1 cell
%  	str2files('pictures/*')
%  	str2files('pictures/*.jpg')
%  	str2files('pictures/*.picture')
%  	str2files('pictures/lanemarking/*shadow*.jp*g')
%  	str2files('*m')

% 特点: 排除子目录、支持通配符、包含路径

if ~isstr(string)
	error('input must be a string');
end

fileList = cell(0);
string = fullfile(string);

[filePath, fileName, fileExt] = fileparts(string);
fileExt = fileExt(2:end);

switch lower(fileExt)
case {'picture', 'img', 'image'};
	ext = {'jpg', 'jpeg', 'png', 'tif', 'bmp', 'pgm', 'ppm'};
	for ii = 1:length(ext)
		files = dir([filePath '\' fileName '.' ext{ii}]);
		fileList = {fileList{:}  files(:).name};
	end
%原来的方法太笨：
%fileList = [];
%fileList = [fileList, struct2cell(dir([filePath '\' fileName '.' ext{ii}]))];

case {'video', 'videos'}
	ext = {'rmvb', 'avi'};
	fileList = [];
	for ii = 1:length(ext)
		files = dir([filePath '\' fileName '.' ext{ii}]);
		fileList = {fileList{:}  files(:).name};
	end

case '' % isempty(fileExt) 
% dir('*.') 后缀名为空的为目录 dir('g*.') dir('.')
% 输入为一个路径
	files = dir(filePath); % 取出目录下全部文件
	for idx = 3 : len  % skip . & ..
		if ~ (files(idx, 1).isdir) % skip sub directory
			fileList{end+1} = files(i,1).name;
		end
	end
otherwise
	files = dir(string);
	fileList = {files(:).name};
% fileList = struct2cell(dir(files)); % 由于只需要文件名，这种方法保留了不必要的信息
end

% 追加路径
for idx = 1:length(fileList)
	fileList{idx} = [filePath, '\', fileList{idx}];
end 

% RootPath = uigetdir;                  %选择任务路径，不可选到式样编号文件夹 
% DirOutput = dir(fullfile(RootPath));  %读取式样编号文件名,dir
% SimpleName = {DirOutput(3:end).name}';%函数读出的结果为结构数组，逗号让它每行一个文件名