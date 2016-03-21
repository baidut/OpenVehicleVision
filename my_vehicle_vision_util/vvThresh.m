classdef vvThresh
%VVFEATURE do binarization
% a color/grayscale image ---> a binary image
%
%   Example
%   -------
%   %  Call static methods. (otsu)
%      colorImage = imread('K:\Documents\MATLAB\dataset\roma\BDXD54\IMG00006.jpg');
%      grayImage = colorImage(:,:,1);
%      BW = vvThresh.otsu(grayImage);
%      imshow(BW);
		
    %% Public properties
    % properties (GetAccess = public, SetAccess = private)
    % end
 
    %% Static methods
    methods (Static)
		function BW = otsu(GrayImg)
		    BW = im2bw(GrayImg, graythresh(GrayImg));
		end
		function BW = otsu2(GrayImg)
            BW = im2bw(GrayImg, graythresh(GrayImg)+0.1);
		end
		function BW = otsu3(GrayImg)
            roi = GrayImg(:,(end-10):end); %floor(end/3):floor(end*2/3)
            medianv = median(roi(:));
%             BW = im2bw(GrayImg, medianv+0.11);
%             return;

            % remove value too big or too small
            maxv = max(GrayImg(:));
            minv = min(GrayImg(:));
            
            %meanv = mean(GrayImg(:,end));
            limitU = (maxv + medianv)/2;%maxv*2/3 + minv*1/3;
            limitL = (minv + medianv)/2;%maxv*1/3 + minv*2/3;%(minv + meanv)/2;
            selected = (GrayImg > limitL) & (GrayImg < limitU); 
		    BW = im2bw(GrayImg, graythresh(GrayImg(selected))*1.3);
		end
		
    end% methods
end% classdef