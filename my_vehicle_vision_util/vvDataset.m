classdef vvDataset
    %VVDATASET handles the dataset related things.
    %
    %   Project website: https://github.com/baidut/openvehiclevision
    %   Copyright 2016 Zhenqiang Ying.
    
    properties
    end
    
    %% Satic methods
    methods (Static)
        
        function vid2img(video, Out)
            %VID2IMG convert video to images
            % video specify the file name of video.
            % Out.namefmt sprintf(namefmt, frameIndex)	default: '%04d'
            % Out.size    [Height Width]                default: input size
            % Out.fps     frameRate 		            default: input frameRate
            %
            %   Example
            %   -------
            %   input_video = '..\dataset\road_dataset_pku\AW_20160204_140415A.mp4';
            %   % using default settings
            %   vvDataset.vid2img(input_video);
            %   % specify out format
            %   Out.namefmt = '%%Out/Frame%04d.jpg'; % use %% instead of %
            %   Out.size = [480 640];
            %   Out.fps = 2;
            %   vvDataset.vid2img(input_video, Out);
            
            if nargin < 2
                Out = struct;
            end
            
            % load default value of parameters.
            if ~isfield(Out, 'size')
                proc = @(x)x; % do nothing
            else
                proc = @(frame) imresize(frame, Out.size);
            end
            
            if ~isfield(Out, 'namefmt')
                Out.namefmt = '%04d';
            end
            
            funct = @(frame, index) imwrite( ...
                proc(frame), ...
                sprintf(Out.namefmt,index) ...
                );
            
            if ~isfield(Out, 'fps')
                foreach_frame_do(video, funct);
            else
                foreach_frame_do(video, funct, Out.fps);
            end
        end
        
    end
end