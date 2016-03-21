roma = vvDataset('%datasets\roma\BDXD54'); % BDXN01 % LRAlargeur13032003
roma_imgs = roma.imgscell('*.jpg');
% figure,montage(cat(4,roma_imgs{:}));



roma_results = cellfun(@vvFeature.shadowfree3, roma_imgs,'UniformOutput',false);
figure,montage(cat(4,roma_results{:}));






sunny = vvDataset('%datasets\nicta-RoadImageDatabase\Sunny-Shadows'); % BDXN01 % LRAlargeur13032003
sunny_imgs = sunny.imgscell('*.tif');
figure,montage(cat(4,sunny_imgs{1:9}));


range = 1:9;
sunny_results = cellfun(@vvFeature.shadowfree3, sunny_imgs(range),'UniformOutput',false);
figure,montage(cat(4,sunny_results{range}), 'DisplayRange', [0 255]);

% please run first!!!

figure,montage(cat(4,sunny_results{range}), 'DisplayRange', [0 50]);



%% origin

roma_results = cellfun(@vvFeature.shadowfree, roma_imgs,'UniformOutput',false);
figure,montage(cat(4,roma_results{:}));

%% new 
roma_results = cellfun(@vvFeature.shadowfree4, roma_imgs,'UniformOutput',false);
figure,montage(cat(4,roma_results{:}));
range = 1:9;
sunny_results = cellfun(@vvFeature.shadowfree4, sunny_imgs(range),'UniformOutput',false);
figure,montage(cat(4,sunny_results{range}), 'DisplayRange', [0 255]);
