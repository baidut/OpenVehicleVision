myPath = {'my_exp_util', 'my_img_util', 'my_vehicle_vision_util', 'my_test', '3rdparty', '3rdparty\Steerable Filters'}; 
% '3rdparty\DIPUM m-files' % Digital image processing using MATLAB
N = length(myPath);
for i = 1 : N
	p = genpath(myPath{i});
	% rmpath(p);
	addpath(p);
end