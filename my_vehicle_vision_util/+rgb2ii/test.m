function test()
% GetInvariantImage
    compare_ii_methods
%   compare_ours_and_others
% test_ours
end

function compare_ii_methods()
inputImage = ImCtrl(@imread, FilePick());
alpha = Slider([0 1], 'Value', 0.2);

will2014 = ImCtrl(@rgb2ii.will2014inv, inputImage, alpha); % .53
alvarez2011 = ImCtrl(@rgb2ii.alvarez2011inv, inputImage, alpha); % .6
Ours = ImCtrl(@dualLaneDetector.rgb2ii_ori, inputImage, alpha); % .06

Fig.subimshow(inputImage, alvarez2011, will2014, Ours);
% Fig.subimwrite(); %auto-write after closed
end

function compare_ours_and_others()
inputImage = ImCtrl(@imread, FilePick());

%% GetInvariantImage
angle = Slider([1 180]);
tipus = Checkbox('norm');
regularize = Checkbox('Discard outliers', 'Value', 1);
InvariantImage = ImCtrl(@GetInvariantImage, inputImage, angle, tipus, regularize);
% roma J = GetInvariantImage(inputImage,88.7100,0,1);

%% will2014
alpha = Slider([0 1], 'Value', 0.2);
ii_image = ImCtrl(@rgb2ii.will2014, inputImage, alpha);

%% S2
% S2 perform badly

% S2 = vvFeature.S2();
% func = @(x)(1-vvFeature.S2(x));
% s2_image = ImCtrl(func, inputImage);

%% ours
Ours = ImCtrl(@dualLaneDetector.rgb2ii_ori, inputImage, alpha);

Fig.subimshow(inputImage, InvariantImage, ii_image, Ours);
% Fig.subimwrite(); %auto-write after closed

end

%% test some varient form of our methods
function test_ours()
inputImage = ImCtrl(@imread, FilePick());
alpha = Slider([0 1], 'Value', 0.2);
Ours = ImCtrl(@dualLaneDetector.rgb2ii, inputImage, alpha);
Log = ImCtrl(@dualLaneDetector.rgb2ii_log, inputImage, alpha);
Eps = ImCtrl(@dualLaneDetector.rgb2ii_eps, inputImage, alpha);

f = Fig;
f.maximize();
f.subimshow(inputImage, Ours, Log, Eps);
end


%% Compare RG space
%% Test rgb2ii methods
% test color image, G-B space.
% find the project relationship
% TODO: share one slider

% R = zeros([256 256], 'uint8'); % repmat(128, [256 256]);
%
% G = repmat( uint8(0:255),  [256 1]);
% B = repmat( uint8(0:255)', [1 256]);
%
%
% RGB = cat(3, R, G, B);
% imshow(RGB);
% imwrite(RGB,'test_rgb2ii.png');