classdef vvShadowFree
    %VVSHADOWFREE compute shadow free image
    %   Evaluate via entropy of output grayscale image.
    
    properties
        
        
        
    end
    
    methods(Static)
        % 
        % vvShadowFree.demo(imread('%datasets\webRoad_pku\shadowy_urban.jpg'));
%         vvShadowFree.demo(imread('%datasets\webRoad_pku\grass_shadow_unstructured.jpg'));
%         vvShadowFree.demo(imread('peppers.png'));
        function demo(I)
            if nargin < 1
%                 I = imread('peppers.png');
%                 I = imread('%datasets\roma\BDXD54\IMG00071.jpg'); % IMG00002 IMG00146
%                 I = imread('%datasets\roma\LRAlargeur13032003\IMG01070.jpg'); % IMG01070 IMG00005 IMG01771 IMG01282
                % IMG01282 not well
%                  I = imread('%datasets\roma\LRAlargeur14062002\IMG00002.jpg');
I = imread('%datasets\nicta-RoadImageDatabase\Sunny-Shadows\261011_p1WBoff_BUMBLEBEE_06102716324103.tif');
            % 261011_p1WBoff_BUMBLEBEE_06102716324200
            % 261011_p1WBoff_BUMBLEBEE_06102716324103
            % 261011_p1WBoff_BUMBLEBEE_06102716324200
            end
            
            thresh = Slider([0 1],'Value', 0.2); % 0.15
            
            ShadowFree = ImCtrl(@vvShadowFree.sf, I, thresh);
            Fig.subimshow(I, ShadowFree);
        end
        
        function sfImg = sf(RGBImage, thresh) % thresh
%             RGBImage = im2int16(RGBImage);
%             R = RGBImage(:,:,1);
%             G = RGBImage(:,:,2);
%             B = RGBImage(:,:,3);
%             SF = 2*( B-( G + thresh)/2 )./ (B+1) ;
%             sfImg = SF; %mat2gray(SF);
%             
%             return;
            % double version
            RGBImage = im2double(RGBImage);
            R = RGBImage(:,:,1);
            G = RGBImage(:,:,2);
            B = RGBImage(:,:,3);
%             sfbwImg = 2 - G./B + B./G;
%             sfbwImg = 1-(G+ thresh -B)./B; %0.2 %0.15
            SF = ( B-( G + thresh)/2 )./ B ;
            % SF(isinf(SF)) = 0; % -Inf -> 0
            SF(SF<0) = 0; % imshow will assume 0-1
            % -Inf will make mat2gray fail!
            sfbwImg = mat2gray( SF);
            % 1-( G + thresh -B)./B; % (R+B)/2 G  R (R+B)/2
            %sfImg(isnan(sfImg)) = 0;
%             sfImg = im2uint8(sfImg);
%             sfImg = edge(sfImg,'canny');
            sfImg = sfbwImg;return; %HSV is bad , strong shadow is blue...

%% Recovery RGB shadow free image.
            
%% YCbCr
%             YCbCr = rgb2ycbcr(RGBImage);
%             YCbCr(:,:,1) = sfbwImg;
%             sfImg = ycbcr2rgb(YCbCr); 
            
%% Lab Bad
            Lab = applycform(RGBImage,makecform('srgb2lab'));
            Lab(:,:,1) = sfbwImg*255;
            sfImg = applycform(Lab,makecform('lab2srgb'));
        global e
            e = entropy(sfImg);
        end
    end
    
end

