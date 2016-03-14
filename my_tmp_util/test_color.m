% test color image, G-B space.
% find the project relationship

R = zeros([256 256], 'uint8'); % repmat(128, [256 256]);

G = repmat( uint8(0:255),  [256 1]);
B = repmat( uint8(0:255)', [1 256]);


RGB = cat(3, R, G, B);
imshow(RGB);


vvShadowFree.demo(RGB);