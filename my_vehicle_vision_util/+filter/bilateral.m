function bflt_img = bilateral(img,w,sigma)
if nargout == 0
    if nargin == 0
        img = double(imread('%datasets\roma\BDXD54\IMG00146_ii.tif'))/255;
        img = impyramid(img,'reduce');
    end
    
    w     = Slider([1 10]);       	% bilateral filter half-width
    sigma = [3 0.1]; 				% bilateral filter standard deviations
    bflt = ImCtrl(@filter.bilateral, img, w, sigma);
    Fig.subimshow(img, bflt);
else
    tic
    bflt_img = bfilter2(img,w,sigma);
    t = toc;
    fprintf('processing time: %fs for an %d x %d x %d image\n',...
        t,size(img,1),size(img,2),size(img,3)...
        );
    fprintf('codegen: bflt_img = bfilter2(img,%d,[%f %f])\n',...
        w,sigma(1),sigma(2)...
        );
end
% very slow, about s for x picture

% http://www.mathworks.com/matlabcentral/fileexchange/12191-bilateral-filtering
% too slow! processing time: 7.401734s for an 512 x 640 x 1 image