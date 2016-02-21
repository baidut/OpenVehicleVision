function h = implot(varargin)
%IMPLOT Plot images.
%   IMPLOT(I,J,K,...) plots I,J,K,... with automatic layout, each input can
%   be a string pecifying the image, a matrix or image data. Filename or
%   variable name of each input and the type of image will be titled.
%
%   Example 1
%   ---------
%   Plot the images of given folder. 
%
%	   Football = imread('football.jpg');
%      Cameraman = imread('cameraman.tif'); 
%	   implot(Football, Cameraman);
%	   implot('kids.tif',rgb2gray(Football), im2bw(Cameraman));
%	   maxfig;
% 
%   Example 2
%   ---------
%   Plot the images of a given folder. 
%
%      files = str2files('dataset/lane detection/*.picture'); 
%      % files = str2files('./*.jpg'); % current folder
%      implot(files{:});
% 	
%   See also SELPLOT.

% Copyright 2015 Zhenqiang YING.  [yingzhenqiang-at-gmail.com] 

h = gcf;

if ~isempty(h.Children) && ~ishold
	h = figure;
end

r = floor(sqrt(nargin));
c = ceil(nargin/r);

for i = 1:nargin
	subplot(r, c, i);
	
	image = varargin{i};
	name = '';

	if ischar(image)
		[~,name,~] = fileparts(image);
		image = imread(image);
    end
	
	if ismatrix(image)  % grey
		if islogical(image)
			imshow(image);
			% name = ['(binary)', name];
		else 
			imshow(image);% imshow(image, []); % 
			% mat2gray(image)
			% imshow(mat2gray(image));
			% name = ['(gray)', name];
		end
	else % color image
		imshow(image);
	end
	%Filtered_Mean -> Filtered_M_e_a_n
	name = [name, inputname(i)]; % 'Filtered_Mean'
	
	% TEST__IMAGE_GRAY
	name = strrep(name, '__', ' '); 
    
%     % 'rawImage' -> 'raw Image'
%     name = regexprep(name,'[A-Z]',' $&'); 
%     
%     % -> 'raw image'
%     name = lower(name);
%     
%     % -> 'Raw image'
%     name(1) = name(1) + 'A' - 'a';

    %% subscript
	% eg: 
	% RGB_R - title('RGB_R')  
	% IMAGE_GRAY - title('IMAGE_G_R_A_Y')
	S = regexp(name, '_', 'split');
	if length(S) == 2
		s1 = S{1}; % Filtered
		s2 = S{2}; % Mean
		s_ = repmat('_',1,length(s2)); 
		t = [s_; s2];
		s2 = t(:)' ; %_M_e_a_n
		name = [s1, s2];
	end
	title(name);
end