function foreach_file_do(files, func, varargin)
% filePath, fileType
% USAGE:
% TIPS: watch a movie by showing pictures! foreach_file_do('SLD2011\dataset3\sequence\01*.jpg', @imshow) 
%  	foreach_file_do('pictures/*', @disp)
%  	foreach_file_do('pictures/*.jpg', @disp)
%  	foreach_file_do('pictures/lanemarking/*.picture', @disp)
%  	foreach_file_do('pictures/*shadow*.picture', @disp)
%  	foreach_file_do('*m', @disp)
%	foreach_file_do('dataset\roma\LRAlargeur26032003\*.jpg', @imshowcolor, 'hsv')
% 'pictures\*.jpg

% 不处理子目录 处理子目录下文件http://blog.sina.com.cn/s/blog_520a99c00101dk41.html
% 函数未定义的error没有弹出

% matlab匿名函数 js http://cn.mathworks.com/help/matlab/matlab_prog/anonymous-functions.html
% foreach_file_do(files, @(I) edge(I,'canny',[t1 t2]), I)
% ```
% figure=edge(I,'canny', [t1 t2]) 
% edgecanny= @(I) edge(I,'canny',[t1 t2]);
% figure = roifilt2(I, mask, edgecanny) 
% ```

 % dir('pictures\*2.jpg')
 
 % dir('pictures\eas*2.jp*')
  
 % 支持矩阵输入和字符串输入两种方式！
 % jp*g
 % bmp

if isstr(files)
	files = str2files(files);
end 

for ii = 1 : size(files, 2)% 修改 注意 length 返回的是行数和列数的最大值
	file = files{1, ii};
	if iscell(file)
		file = cell2mat(file);
	end
	func( file, varargin{:} );
end

return;

% 以下为旧版代码
% function foreach_file_do(filePath, fileType, func, varargin)
%  	foreach_file_do('./','', @disp)
%	foreach_file_do('./pictures/','png', @disp)
%	foreach_file_do('./pictures/','picture', @disp)
%	foreach_file_do('./pictures/','picture', @imshow)
% if nargin < 1
	% path = './'; % default: current folder
% end

if( filePath(end) ~='/' && filePath(end) ~='\' )
	filePath = [filePath, '/'];
end

% fullfile创建跨平台的文件路径，会将字符串里的/转为\ 在windows下两者都可以，但是linux下之能用\
files = dir(fullfile(filePath)); % dir(fullfile(path,fileExt));  
len = size(files,1); 

for i = 3 : len  % skip . & ..
	file = files(i,1).name;
	
	if ~ (files(i,1).isdir) % skip sub directory
	
		% check fileType
		if ~isempty(fileType)
			[junk, fileName, fileExt] = fileparts(file);
			fileExt = fileExt(2:end);
			fileExt = lower(fileExt);
			
			if ~strcmp(fileExt, fileType) 
				switch (fileExt)
				case {'png', 'jpg', 'bmp', 'jpeg', 'tif'}
					if ~strcmp('picture', fileType)
						continue;
					end
				
				case {'rmvb', 'avi'}
					if ~strcmp('video', fileType)
						continue;
					end
				
				otherwise
					disp(['unknown file type:', fileExt]);
					continue;
					
				end % switch (fileExt)
			end % if fileExt ~= fileType
		end % if ~isempty(fileType)
		
		%figure; %方便显示
		func([filePath, file], varargin{:} );
	end
end