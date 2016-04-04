function ii_image = maddern2014(image, alpha, inv)
%RGB2II convert a RGB image to a illumination invariant grayscale image
% using the algorithm proposed by Will Maddern in ICRA2014.
% Paper:
% Illumination Invariant Imaging: Applications in Robust Vision-based
% Localisation, Mapping and Classification for Autonomous Vehicles

image = im2double(image);

ii_image = 0.5 + log(image(:,:,2)) - ...
    alpha*log(image(:,:,3)) - (1-alpha)*log(image(:,:,1));

if nargin>2 && inv % default: do not inverse
	ii_image = 1-ii_image;
end	
	
end