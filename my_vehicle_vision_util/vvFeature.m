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
            Gray = sqrt(double(RGB_max.^2 - RGB_min.^2) ./ double(RGB_max.^2 + 1));
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
        
		%% Binary image
		
		%function Bw = lightness(Rgb)
		% 	Bw = vvThresh.otsu(Rgb);
		%end
        
        function hsvhist(rgb)
            % with little modification
            % http://www.mathworks.com/matlabcentral/newsreader/view_thread/285992
            %imhist is very time-consuming when numberOfBins is too big
            hsv = rgb2hsv(rgb);
            h = hsv(:, :, 1);
            s = hsv(:, :, 2);
            v = hsv(:, :, 3);
            numberOfBins = 16;%50; % or whatever.
            
            hist_func = @imhist; %hist
            % Get the histogram of the H channel.
            [countsH, valuesH] = hist_func(h, numberOfBins);
            figure;
            subplot(2, 2, 1);
            bar(valuesH, countsH, 'BarWidth', 1);
            title('Histogram of the H Channel', 'FontSize', 15);
            % Get the histogram of the S channel.
            [countsS, valuesS] = hist_func(s, numberOfBins);
            subplot(2, 2, 2);
            bar(valuesS, countsS, 'BarWidth', 1);
            title('Histogram of the S Channel', 'FontSize', 15);
            % Get the histogram of the V channel.
            [countsV, valuesV] = hist_func(v, numberOfBins);
            subplot(2, 2, 3);
            bar(valuesV, countsV, 'BarWidth', 1);
            title('Histogram of the V Channel', 'FontSize', 15);
        end
        
        function hist2d_hs(rgbImage)
            % http://www.mathworks.com/matlabcentral/newsreader/view_thread/264526
            %             rgbImage = imread('peppers.png');
            [rows columns] = size(rgbImage);
            subplot(3,3,1);
            imshow(rgbImage);
            title('Color Image');
            set(gcf, 'Position', get(0, 'ScreenSize')); % Maximize figure.
            
            % Convert to hsv
            hsvImage = rgb2hsv(rgbImage);
            subplot(3,3,2);
            imshow(hsvImage, []);
            title('HSV Image');
            
            % Extract out H, S, and V channels and display them
            H_Channel = hsvImage(:,:,1);
            subplot(3,3,4);
            imshow(H_Channel, []);
            title('H Image');
            S_Channel = hsvImage(:,:,2);
            subplot(3,3,5);
            imshow(S_Channel, []);
            title('S Image');
            V_Channel = hsvImage(:,:,3);
            subplot(3,3,6);
            imshow(V_Channel, []);
            title('V Image');
            
            % Get hist of H channel
            numberOfBins = 16;
            [hCounts hValues] = hist(H_Channel(:), numberOfBins);
            subplot(3,3,7);
            bar(hValues, hCounts);
            title('Histogram of H Channel');
            
            % Get hist of S channel
            [sCounts sValues] = hist(S_Channel(:), numberOfBins);
            subplot(3,3,8);
            bar(sValues, sCounts);
            title('Histogram of S Channel');
            
            % Get hist of V channel
            [vCounts vValues] = hist(V_Channel(:), numberOfBins);
            subplot(3,3,9);
            bar(vValues, vCounts);
            title('Histogram of V Channel');
            
            % Construct 2D histogram with H along vertical and S along horizontal.
            [rows cols numberOfChannels] = size(hsvImage);
            maxH = max(max(H_Channel))
            maxS = max(max(H_Channel))
            hist2d = zeros(numberOfBins+1, numberOfBins+1);
            for col = 1 : cols
                for row = 1 : rows
                    r = int32(H_Channel(row, col) * numberOfBins) + 1;
                    c = int32(S_Channel(row, col) * numberOfBins) + 1;
                    hist2d(r, c) = hist2d(r, c) + 1;
                end
            end
            subplot(3,3,3);
            imshow(hist2d, []);
            title('2D Histogram of H vs. S');
        end
        
    end% methods
end% classdef