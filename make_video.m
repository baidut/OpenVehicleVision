
function make_video(out_file,img_filter)
% make avi video 
% out_file 'output_avi_file_name'
% img_filter '*.ppm'
% clear all; close all; clc;
srcDir=uigetdir('Choose source directory.'); %获得选择的文件夹
cd(srcDir);
allnames=struct2cell(dir(img_filter));
[k,len]=size(allnames); %获得文件的个数


%aviobj = avifile(out_file,'compression','none');
v = VideoWriter(out_file);
open(v);
for i=1:len
    %逐次取出文件
    name=allnames{1,i};
    rgb=imread(name); %读取文件
    %判断图像是否为灰度图像
	if numel(size(rgb))>2
	 %彩色图像
		I=rgb;
	else
		I(:,:,1)=rgb;
		I(:,:,2)=rgb;
		I(:,:,3)=rgb;
	end
    % aviobj = addframe(aviobj,I);
	writeVideo(v,I);
end
%aviobj = close(aviobj);
close(v);
msgbox(strcat(out_file,' OK!'));
