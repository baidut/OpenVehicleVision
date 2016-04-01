%% 3D shadow free image
function figure_in_paper_mm2016

% rgb2ii_3d;
% ii_ours_on_kitti;
% ii_ours_on_roma;
road_seg_based_on_ii;

end

function road_seg_based_on_ii()
% .05*255 \LRAlargeur13032003\IMG02210 
% 0.2*255 \BDXD54\IMG00002
    rawImg = imread('%datasets\roma\BDXD54\IMG00002.jpg');
    rawImg = impyramid(rawImg,'reduce');
    rawImg = impyramid(rawImg,'reduce');
    rawImg = impyramid(rawImg,'reduce');
    rawImg = rawImg(ceil(end/2):end,:,:);
    ii_method = @(rgb) rgb2ii_2d(rgb,[2,3],.2*255);
    ii_image = road_detection_via_ii(rawImg, ii_method, {}, 1);
end

function ii_ours_on_kitti()
    disp('see rgb2ii.demo');
end

function ii_ours_on_roma()
    rgb = imread('%datasets\roma\BDXD54\IMG00002.jpg');
    rgb = impyramid(rgb,'reduce');
    rgb = impyramid(rgb,'reduce');
    rgb = impyramid(rgb,'reduce');
    gray = im2double(rgb2gray(rgb));
    ii = rgb2ii_2d(rgb,[2,3],0.2*255);
    alvarez2011 = rgb2ii.alvarez2011(rgb,0.1471,0);
    will2014 = rgb2ii.will2014inv(rgb,0.6029);
    
    compare_ii = [gray, ii, alvarez2011, will2014];
    compare = [im2double(rgb), repmat(compare_ii,[1 1 3])];
    imshow(compare);
    imwrite(compare,'%results/ii_ours_on_roma.jpg');
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