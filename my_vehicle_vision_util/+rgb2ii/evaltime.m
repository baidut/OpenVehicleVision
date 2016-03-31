function t = evaltime

% warm up
image = imread('%datasets\roma\BDXD54\IMG00002.jpg');

%% for different size
imshow(rgb2ii.ying2016(image,51)); % 0.2*255


times = 100;

tic
for n = 1:times
    rgb2ii.ying2016(image,51);
end
t = toc/times;
disp(t);

end