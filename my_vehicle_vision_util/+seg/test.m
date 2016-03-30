classdef test
    methods
        function obj = test()
        end
    end
    methods (Static)
		function FCM(im)
			% im=imread('cameraman.tif'); % sample image
			[L,C,U,LUT,H]=FastFCMeans(im,3); % perform segmentation
			 
			% Visualize the fuzzy membership functions
			figure('color','w')
			subplot(2,1,1)
			I=double(min(im(:)):max(im(:)));
			c={'-r' '-g' '-b'};
			for i=1:3
				plot(I(:),U(:,i),c{i},'LineWidth',2)
				if i==1, hold on; end
				plot(C(i)*ones(1,2),[0 1],'--k')
			end
			xlabel('Intensity Value','FontSize',30)
			ylabel('Class Memberships','FontSize',30)
			set(gca,'XLim',[0 260],'FontSize',20)
			 
			subplot(2,1,2)
			plot(I(:),LUT(:),'-k','LineWidth',2)
			xlabel('Intensity Value','FontSize',30)
			ylabel('Class Assignment','FontSize',30)
			set(gca,'XLim',[0 260],'Ylim',[0 3.1],'YTick',1:3,'FontSize',20)

			% Visualize the segmentation
			figure('color','w')
			subplot(1,2,1), imshow(im)
			set(get(gca,'Title'),'String','ORIGINAL')
			 
			Lrgb=zeros([numel(L) 3],'uint8');
			for i=1:3
				Lrgb(L(:)==i,i)=255;
			end
			Lrgb=reshape(Lrgb,[size(im) 3]);

			subplot(1,2,2), imshow(Lrgb,[])
			set(get(gca,'Title'),'String','FUZZY C-MEANS (C=3)')

			% If necessary, you can also unpack the membership functions to produce 
			% membership maps
			Umap=FM2map(im,U,H);
			figure('color','w')
			for i=1:3
				subplot(1,3,i), imshow(Umap(:,:,i))
				ttl=sprintf('Class %d membership map',i);
				set(get(gca,'Title'),'String',ttl)
			end
		
		end
        function adaptCluster
            seg.test.onShadowFreeImage(@adaptcluster_kmeans);
        end
        function kmeans
            seg.test.onShadowFreeImage(@proc);
            function mask = proc(ima)
                [~,mask]=kmeans(ima,3);
            end
        end
        
        function onShadowFreeImage(algo, inputImage)
            if nargin < 2
                inputImage = ImCtrl(@imread, FilePick());
            end
            labelImage = ImCtrl(@segment, inputImage);
            Fig.subimshow(inputImage, labelImage);
            
            function labelImg = segment(rgbImg)
                % ii image need to be filtered before being used.
                rgbImg = rgbImg(ceil(end/2):end,:,:);
                ii_image = dualLaneDetector.rgb2ii(rgbImg, 0.2);
                smoothed = medfilt2(ii_image,[10 10]);% size should be adaptive
                label = algo(smoothed);
                labelImg = label2rgb(label);
            end
        end
        
    end
    % strong_shadow = imread('D:\Documents\MATLAB\OpenVehicleVision\%datasets\roma\BDXD54\IMG00002.jpg');
    % ('%datasets\nicta-RoadImageDatabase\Sunny-Shadows\261011_p1WBoff_BUMBLEBEE_06102716324102.tif')
end