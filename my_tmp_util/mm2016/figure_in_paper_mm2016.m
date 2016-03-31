%% 3D shadow free image
function figure_in_paper_mm2016



rgb2ii_3d;
% ii_ours_on_kitti;
% ii_ours_on_roma;

end

function ii_ours_on_kitti()
    disp('see rgb2ii.demo');
end

function ii_ours_on_roma()
    rgb = imread();
    rgb2ii_2d(rgb,[2,3],0.2*255);
end

function ii = rgb2ii_2d(rgb, chns, c)
% since the / we cannot use int type
% log 
    rgb = double(rgb); % im2int16 will do rescaling, so int16 should be used
    
    R1 = rgb(:,:,chns(1));
    R2 = rgb(:,:,chns(2));
    
    ii =  2 - (R1+c)./(R2+1); % +1 to avoid /0
%     max(ii(:))
%     min(ii(:))
    ii(ii<0) = 0;
    ii(ii>1) = 1; % ii double
end


function rgb2ii_3d()
rgb = imread('%datasets\KITTI\data_road\training\image_2\uu_000086.png');

ii2dRG = rgb2ii_2d(rgb,[1,2],12.4501); % dR > dG
ii2dGB = rgb2ii_2d(rgb,[2,3],18.7499); % dG > GB
ii2dRB = rgb2ii_2d(rgb,[1,3],27.9750); % dR > GB
ii = cat(3, ii2dRB, ii2dRG, ii2dGB);

fig = [im2double(rgb); ii];

imwrite(fig,'%results/rgb2ii_3d.jpg');
end