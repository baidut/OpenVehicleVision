function nameFolds = subfolder(pathFolder)
%SUBFOLDER list the subfolders in a folder
%nameFolds = subfolder(pathFolder)
%http://stackoverflow.com/questions/8748976/list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files

%Use isdir field of dir output to separate subdirectories and files:
d = dir(pathFolder);
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';
%You can then remove . and ..
nameFolds(ismember(nameFolds,{'.','..'})) = [];
%You shouldn't do nameFolds(1:2) = [], since dir output from root %directory does not contain those dot-folders. At least on Windows.
