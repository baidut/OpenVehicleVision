function ii = rgb2ii_2d(rgb, c, chns)
% since the / we cannot use int type
% log 
    if nargin < 3
        chns = [2,3]; % gb2ii
    end
%     c = c*255;

    rgb = double(rgb); % im2int16 will do rescaling, so int16 should be used
    
    R1 = rgb(:,:,chns(1));
    R2 = rgb(:,:,chns(2));
    
    ii =  2 - (R1+c)./(R2+1); % +1 to avoid /0
%     max(ii(:))
%     min(ii(:))
    ii(ii<0) = 0;
    ii(ii>1) = 1; % ii double
end