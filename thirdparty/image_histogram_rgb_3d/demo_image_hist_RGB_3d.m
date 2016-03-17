% Demonstrates the 3D-histogram made from an RGB image

close all

figure
imshow('baboon_small.jpg');
[freq, freq_emph, freq_ly] = image_hist_RGB_3d('baboon_small.jpg',6)

% pause

figure
imshow('clown.jpg');
[freq, freq_emph, freq_ly] = image_hist_RGB_3d('clown.jpg',5);


% pause

im = rgb_noise_image(200,300,'rgb_noise.png');
figure
imshow('rgb_noise.png');
[freq, freq_emph, freq_ly] = image_hist_RGB_3d('rgb_noise.png',4);