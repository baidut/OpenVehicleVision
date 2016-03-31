
%% Show video
%{
src = '%datasets\nicta-RoadImageDatabase\Sunny-Shadows\*.tif';

% imgFile = foreach_file_do(src,@(x)x);
rawImg = foreach_file_do(src,@imread); %slow
rawImg = cellfun(@(im)impyramid(im,'reduce'),rawImg,'UniformOutput',false);

grayImg = cellfun(@(im)im2double(rgb2gray(im)),rawImg,'UniformOutput',false);
invariant = cellfun(@(im)GetInvariantImage(im,36,0,1), rawImg,'UniformOutput',false);
will2014 = cellfun(@(im)rgb2ii.will2014(im,.42), rawImg,'UniformOutput',false);
ours = cellfun(@(im)dualLaneDetector.rgb2ii(im,256*.06),rawImg,'UniformOutput',false); % .05 .10 is too dark

% very slow
% frame = [cat(3,grayImg{:}) cat(3,invariant{:}); ...
%          cat(3,will2014{:}) cat(3,ours{:})];
% Error using horzcat
% Out of memory. Type HELP MEMORY for your options. 
grayVid = cat(3,grayImg{:}); % slow, very fast after downsample
invaVid = cat(3,invariant{:});
willVid = cat(3,will2014{:});
oursVid = cat(3,ours{:});
implay([grayVid invaVid;...
        oursVid willVid]);
%}    
%% KITTI
% for kitti need to inverse

% image size is not unique in kitti
% src = '%datasets\KITTI\data_road\training\image_2\*.png';
% rawImg = foreach_file_do(src,@imread); 

% src = vvDataset('%datasets\KITTI\data_road\training\image_2\');

files = foreach_file_do('%datasets\KITTI\data_road\training\image_2\*.png',@(x)x);

% %% biggest size
% imgscell = cellfun(@imread,files,'UniformOutput',false);
% imgsSize = cellfun(@(x)transpose(size(x)),imgscell,'UniformOutput',false);
% maxSize = max([imgsSize{:}].'); % imgsSize is an 1*N cell array
% disp(maxSize);% 376        1242           3

N = numel(files);
im = imread(files{1});
maxSize = [376 1242];
frames = zeros([maxSize.*[2 1] 3 N]);

for k = 1:N
    disp(k/N);
    im = imread(files{k});
    im = padarray(im,[maxSize 3]-size(im),0,'post');
            
    imr = impyramid(im,'reduce');
    
    grayImg = im2double(rgb2gray(imr));
    alvarez2011 = rgb2ii.alvarez2011inv(imr,.6);
    will2014 = rgb2ii.will2014inv(imr,.53);
    ours = dualLaneDetector.rgb2ii_ori(imr,.06);
    
    lowhalf = repmat([grayImg alvarez2011;...
                     ours will2014], [1,1,3]); % gray to rgb
    
    % Frames of type double must be in the range 0 to 1.
    lowhalf(lowhalf>1) = 1;
    lowhalf(lowhalf<0) = 0;
    frames(:,:,:,k) = [im2double(im);lowhalf];
end

disp('Saving frames...'); % save/load are time-consuming
save('%mat/ii_KITTI_data_road_training_image_2.mat','frames','-v7.3');
implay(frames);

disp('Writing to files...');

v = VideoWriter('%results/ii_KITTI_data_road_training_image_2.avi');
open(v);

for k = 1:N % N = 289
   disp(k/N);
   frame = frames(:,:,:,k); % double image will become gray
   writeVideo(v,frame);
end

close(v);

%282 285

