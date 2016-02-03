classdef vvFeature
    %VVFEATURE Extract Feature Map
    % a color image ---> a grayscale image
    %
    %   Example
    %   -------
    %   %  Call static methods.
    %      colorImage = imread('K:\Documents\MATLAB\dataset\roma\BDXD54\IMG00006.jpg');
    %      S2 = vvFeature.S2(colorImage);
    %      imshow(S2);
    %
    %   Project website: https://github.com/baidut/openvehiclevision
    %   Copyright 2016 Zhenqiang Ying.
    
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
            % this feature is unstable, use S2 instead.
            [R, G, B] = getChannel(Rgb);
            Gray = mat2gray(R + G - 2 * B);
            % note image is unsigned (uint8), so it >= 0
        end
        
        function ii_image = rgb2ii(image)
            %RGB2II convert a RGB image to a illumination invariant grayscale image
            % using the algorithm proposed by Will Maddern in ICRA2014.
            % Paper:
            % Illumination Invariant Imaging: Applications in Robust Vision-based
            % Localisation, Mapping and Classification for Autonomous Vehicles
            
            % Chang log:
            % add default alpha 0.5
            % fix bug: Undefined function 'log' for input arguments of type 'uint8'.
            
            if nargin < 2
                alpha = 0.5;
            end
            
            image = im2double(image);
            
            ii_image = 0.5 + log(image(:,:,2)) - ...
                alpha*log(image(:,:,3)) - (1-alpha)*log(image(:,:,1));
            
        end
        %% color feature
        
        function Gray = blueness(Rgb)
            [R, G, B] = getChannel(Rgb);
            Gray = mat2gray(B - max(R, G));
        end
        
        function Gray = greenness(Rgb)
            [R, G, B] = getChannel(Rgb);
            Gray = mat2gray(G - max(R, B));
        end
        
        function Gray = redness(Rgb)
            [R, G, B] = getChannel(Rgb);
            Gray = mat2gray(R - max(G, B));
        end
        
    end% methods
end% classdef