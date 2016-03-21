classdef vvHist
    %VVHIST
    %
    %   Example
    %   -------
    %
    %   Project website: https://github.com/baidut/openvehiclevision
    %   Copyright 2016 Zhenqiang Ying.
    
    %% Public properties
    % properties (GetAccess = public, SetAccess = private)
    % end
	
	% hist is not recommended. Use histogram instead.
    
    %% Static methods
    
    %% Superpixel
    methods (Static)
		function demo(inRGB)
		% input is an array, 
		% select bar can disp in image
		% show RGB 
			%[h, s, v]
			
			% RGB = ColorImg(inRGB);
			% nbins = 20;
			% show_hist = @(x)(histogram(x(:), nbins));
			% RGB.eachChn(show_hist);
		end
		
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
