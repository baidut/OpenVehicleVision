% dualLaneDetector('%datasets\SLD2011\dataset3\sequence\01640.jpg',0);
% 80 images
% 10.920 s 
% 9.951 s im2double -> double
% 6.485 s medfilt -> wiener2
foreach_file_do('%datasets\SLD2011\dataset3\sequence\*.jpg',@(x)dualLaneDetector(x,0));