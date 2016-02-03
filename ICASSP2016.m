%% Robust Lane Marking Detection using Boundary-Based Inverse Perspective Mapping
% (Zhenqiang Ying & Ge Li) to appear in IEEE-ICASSP2016
% (IEEE International Conference on Acoustics, Speech and Signal Processing 2016) conference.
%
% Email: yinzhenqiang # gmail.com
% Website: https://github.com/baidut/openvehiclevision

global dumpLevel;
global saveEps;
global dumpPath;
global dodumpFigureInPaper;

setup;
%mkdir('results');
dumpPath = '.\results';
dumpLevel = 0;
saveEps = false;
dodumpFigureInPaper= false;

% Test on a single image
colorImage = imread('K:\Documents\MATLAB\dataset\roma\LRAlargeur13032003\IMG00576.jpg');
roadDetectionViaBird(colorImage);

% Test on images
Test = vvTest(@roadDetectionViaBird);
Test.onImages('K:\Documents\MATLAB\dataset\roma\LRAlargeur13032003\*.jpg');