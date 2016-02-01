classdef vvFeature
%VVFEATURE Extract Feature Map
% a color image ---> a grayscale image

%   Example
%   -------
%   %  Call static methods.
%      colorImage = imread('K:\Documents\MATLAB\dataset\roma\BDXD54\IMG00006.jpg');
%      S2 = vvFeature.S2(colorImage);
%      imshow(S2);
		
    %% Public properties
    % properties (GetAccess = public, SetAccess = private)
    % end
 
    %% Static methods
    methods (Static)
	
		function Gray = S(Rgb)
            [R, G, B] = getChannel(Rgb);
            RGB_max = max(max(R, G) , B);
			RGB_min = min(min(R, G) , B);
            Gray = double(RGB_max - RGB_min) ./ double(RGB_max + 1);
        end
	
        function Gray = S2(Rgb)
            [R, G, B] = getChannel(Rgb);
            RGB_max = max(max(R, G) , B);
            Gray = double(RGB_max - B) ./ double(RGB_max + 1);
        end
        
        function Gray = RpGm2B(Rgb)
            [R, G, B] = getChannel(Rgb);
            Gray = mat2gray(R + G - 2 * B); 
			% note image is unsigned (uint8), so it >= 0
        end
		
		%% color feature
		
		function Gray = blueness()
			[R, G, B] = getChannel(Rgb);
			Gray = mat2gray(B - max(R, G));
		end
		
		function Gray = greeness()
			[R, G, B] = getChannel(Rgb);
			Gray = mat2gray(G - max(R, B));
		end
		
		function Gray = redness()
			[R, G, B] = getChannel(Rgb);
			Gray = mat2gray(R - max(G, B));
		end
		
    end% methods
end% classdef