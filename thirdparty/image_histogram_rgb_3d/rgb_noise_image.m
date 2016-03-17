function image = rgb_noise_image(rows,cols,filename)

% generates random RGB image of specified size

image = randi([0,255],rows,cols,3);
image = uint8(image);

if nargin > 2
    if ischar(filename)
        imwrite(image,filename)
    end
end