classdef vvShadowFree
    %VVSHADOWFREE compute shadow free image
    %   Evaluate via entropy of output grayscale image.
    
    properties
        
        
        
    end
    
    methods(Static)
        function demo(I)
            if nargin < 1
%                 I = imread('peppers.png');
                I = imread('%datasets\roma\BDXD54\IMG00002.jpg');
            end
            
            thresh = Slider([0 1]);
            
            ShadowFree = ImCtrl(@vvShadowFree.sf, I, thresh);
            Fig.subimshow(I, ShadowFree);
        end
        
        function sfImg = sf(RGBImage, thresh)
            RGBImage = im2double(RGBImage);
            G = RGBImage(:,:,2);
            B = RGBImage(:,:,3);
            sfImg = (G+thresh-B)./B; %0.2
        global e
            e = entropy(sfImg);
        end
    end
    
end

