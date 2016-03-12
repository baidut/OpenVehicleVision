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
        
        function Gray = shadowfree(Rgb)
        % roma = vvDataset('%datasets\roma\BDXD54'); % BDXN01 % LRAlargeur13032003
        % imgs = roma.imgscell('*.jpg');
        % results = cellfun(@vvFeature.shadowfree, imgs,'UniformOutput',false);
        % figure,montage(cat(4,imgs{:}));
        % figure,montage(cat(4,results{:}));
        
%             [~, G, B] = getChannel(Rgb);
%             Gray = (G+255-B);

              [~, G, B] = getChannel(im2double(Rgb));
              %Gray = abs(G+0.18-B)./B; 
              Gray = (G+0.2-B)./B; % (G+0.18-B)./B
              % avoid exceed 1 (saturate)
        end
        
        function r = road(Rgb)
            sf = vvFeature.shadowfree(Rgb(floor(end/2):end,:,:));
            r = vvThresh.otsu(sf);
        end
        
        function Gray = Slog(Rgb)
            [R, G, B] = getChannel(Rgb);
            RGB_max = max(max(R, G) , B);
            RGB_min = min(min(R, G) , B);
            Gray = sqrt(double(RGB_max.^2 - RGB_min.^2) ./ double(RGB_max.^2 + 1));
        end
        
        function Gray = Slog2(Rgb)
            [R, G, B] = getChannel(Rgb);
            RGB_max = max(max(R, G) , B);
            RGB_min = min(min(R, G) , B);
            Gray = sqrt(double(RGB_max.^2 - B.^2) ./ double(RGB_max.^2 + 1));
        end
        
        function Gray = RpGm2B(Rgb)
            % this feature is unstable, use S2 instead.
            [R, G, B] = getChannel(Rgb);
            Gray = mat2gray(R + G - 2 * B);
            % note image is unsigned (uint8), so it >= 0
        end
        
        %% II features
        function ii_image = rgb2ii(image, alpha)
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
        function Gray = ii(Rgb, a)
            %RGB2II convert a RGB image to a illumination invariant grayscale image
            % using the algorithm proposed by Will Maddern in ICRA2014.
            % Paper:
            % Illumination Invariant Imaging: Applications in Robust Vision-based
            % Localisation, Mapping and Classification for Autonomous Vehicles
            
            % Chang log:
            % add default alpha 0.5
            % fix bug: Undefined function 'log' for input arguments of type 'uint8'.
            
%             if nargin < 2
%                 alpha = 0.5;
%             end
%             
%             image = im2double(image);
%             
%             ii_image = 0.5 + log(image(:,:,3)) - ...
%                 alpha*log(image(:,:,2)) - (1-alpha)*log(image(:,:,1));

            [R, G, B] = getChannel(im2double(Rgb));
            RGB_max = max(max(R, G) , B);
            RGB_min = min(min(R, G) , B);
            Gray = double(RGB_max - a*B) ./ double(RGB_max + 1);
            Gray = mat2gray(Gray);
        end
        
        %% Finlayson old code
        function gfinvim(I)
            % Demostration of Graham Finlayson's Invariant Image Derivation
            
            %   References:
            %      Graham Finlayson et al. "Entropy Minimization for Shadow Removal".
            %      IJCV, 2009.
            
            % Copyright 2014 Han Gong, University of Bath
            
            %I = imread('../data/fail2.tif'); % read an image
            [I1D,IL1] = gfinvim(I,'entropy','shannon','demo',true);
            figure;
            subplot(1,3,1); imshow(I); title('original');
            subplot(1,3,2); imshow(I1D); title('1D invariant');
            subplot(1,3,3); imshow(IL1); title('L1 chromaticity');
        end
        
        function rgb = iinv(I)
            rgb = iinv(I);
        end
        
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
        
        %% Binary image
        
        %function Bw = lightness(Rgb)
        % 	Bw = vvThresh.otsu(Rgb);
        %end
        
    end% methods
end% classdef