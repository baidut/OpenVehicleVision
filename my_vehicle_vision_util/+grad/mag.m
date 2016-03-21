function gradmag = mag(I)
% grayscale image
%http://cn.mathworks.com/help/images/examples/marker-controlled-watershed-segmentation.html?s_tid=srchtitle

hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);

end