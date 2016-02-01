classdef vvTest < handle
%%VVTEST implements the testing module of VV lib.
% 
%   Example
%   -------
%   %  Test IMSHOW.
%      Test = vvTest(@imshow);
%      Test.onImages('K:\Documents\MATLAB\dataset\roma\BDXD54\*.jpg');
%      Test.onVideo('K:\Documents\MATLAB\dataset\SLD2011\dataset1\sequence_1.mpg');
%
%   %  Test roadDetection.
%      Test.algo = @roadDetection;
%      Test.onFiles('K:\Documents\MATLAB\dataset\roma\BDXD54\*.jpg');
%
%   Project website: https://github.com/baidut/openvehiclevision
%   Copyright 2016 Zhenqiang Ying.

    properties
        algo
    end
 
    methods
        function Test = vvTest(algo)
            Test.algo = algo;
        end
        
        function onFiles(Test, files)
            foreach_file_do(files, Test.algo);
        end
        
        function onImages(Test, images, dotracking)
        % Test on a single image or image sequence.
            if nargin<3
                dotracking = 0;
            end
            
            if dotracking
                % Test on image sequence (tracking on)
                infor = 0;
                foreach_file_do(images, @(file) { ...
                    figure('NumberTitle', 'off', 'Name', file), ...
                    assign(infor, Test.algo(imread(file), infor)) ...
                });
            else
                % Test on irrelevant images (tracking off)
                foreach_file_do('', @(file) { ...
                    figure('NumberTitle', 'off', 'Name', file), ...
                    Test.algo(imread(file)) ...
                });
            end
        end
        
        function onVideo(Test, video, dotracking)
            % Test on video (tracking off)
            if nargin<3
                dotracking = 0;
            end
            
            if dotracking
                infor = 0;
                foreach_frame_do(video, @(frame) { ...
                    figure('NumberTitle', 'off', 'Name', frame), ...
                    assign(infor, Test.algo(frame, infor)) ...
                });
            else 
                foreach_frame_do(video, @(frame) Test.algo(frame) );
            end
        end
    end
end 