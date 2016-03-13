classdef vvShadowFree
    %VVSHADOWFREE compute shadow free image
    %   Evaluate via entropy of output grayscale image.
    
    properties
        
        
        
    end
    
    methods(Static)
%         vvShadowFree.demo(imread('%datasets\webRoad_pku\grass_shadow_unstructured.jpg'));
%         vvShadowFree.demo(imread('peppers.png'));
        function demo(I)
            if nargin < 1
%                 I = imread('peppers.png');
                I = imread('%datasets\roma\BDXD54\IMG00071.jpg'); % IMG00002 IMG00146
%                 I = imread('%datasets\roma\LRAlargeur13032003\IMG01070.jpg'); % IMG01070 IMG00005 IMG01771 IMG01282
                % IMG01282 not well
%                  I = imread('%datasets\roma\LRAlargeur14062002\IMG00002.jpg');
% I = imread('%datasets\nicta-RoadImageDatabase\Sunny-Shadows\261011_p1WBoff_BUMBLEBEE_06102716324200.tif');
            % 261011_p1WBoff_BUMBLEBEE_06102716324200
            % 261011_p1WBoff_BUMBLEBEE_06102716324103
            end
            
            thresh = Slider([0 1],'Value', 0); % 0.15
            
            ShadowFree = ImCtrl(@vvShadowFree.sf, I, thresh);
            Fig.subimshow(I, ShadowFree);
        end
        
        function sfImg = sf(RGBImage, thresh)
            RGBImage = im2double(RGBImage);
%             R = RGBImage(:,:,1);
            G = RGBImage(:,:,2);
            B = RGBImage(:,:,3);
%             sfbwImg = 2 - G./B + B./G;
            sfbwImg = 1-(G+ thresh -B)./B; %0.2 %0.15
            %sfImg(isnan(sfImg)) = 0;
%             sfImg = im2uint8(sfImg);
%             sfImg = edge(sfImg,'canny');
            sfImg = sfbwImg;return;
            HSV = rgb2hsv(RGBImage);
            HSV(:,:,3) = sfbwImg;
            sfImg = hsv2rgb(HSV); % strong shadow is blue...
        global e
            e = entropy(sfImg);
        end
    end
    
end

