classdef vvDataset
    %VVDATASET handles the dataset related things.
    %
    %   Project website: https://github.com/baidut/openvehiclevision
    %   Copyright 2016 Zhenqiang Ying.
    
    properties
    end
    
    %% Satic methods
    methods (Static)
        
        function roi = selroi(video, roi_size)
            % select region of interest
            % GUI tool for choosing roi
        end
        
        function vid2img(video, Out)
            %VID2IMG convert video to images
            % video specify the file name of video.
            % Out.namefmt sprintf(namefmt, frameIndex)	default: '%04d'
            % Out.roi     {rows, cols}                  default: {1:height,1:width }
            % Out.size    [Height Width]                default: input size
            % Out.fps     frameRate 		            default: input frameRate
            %
            %   Note
            %   -------
            %   Resize operation is after roi selection, so the rows and
            %   cols is about the input frames.
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
            
            % todo: roi tool, do not resize, select center roi
            
            if nargin < 2
                Out = struct;
            end
            
            vidObj = VideoReader(video);
            
            %% load default settings
            if ~isfield(Out, 'namefmt')
                Out.namefmt = '%04d';
            end
            
            if ~isfield(Out, 'fps')
                Out.fps = vidObj.FrameRate;
            end
            
            if ~isfield(Out, 'roi')
                Out.roi = {1:vidObj.Height,1:vidObj.Width };
            end
            
            if ~isfield(Out, 'size')
                Out.size = [vidObj.Height, vidObj.Width];
            end

            for n = 1 : vidObj.FrameRate/Out.fps : vidObj.NumberOfFrames
                idx = uint32(round(n));
                vidFrame = read(vidObj, idx);
                
                roi = vidFrame(Out.roi{1},Out.roi{2},:);
                resized = imresize(roi, Out.size);
                imwrite( resized, sprintf(Out.namefmt,idx) );
                disp( sprintf(['%2d%% done:' Out.namefmt],ceil(100*n/vidObj.NumberOfFrames),idx) );
            end
            
            disp('ok');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%             %% old way     
%             % load default value of parameters.
%             if ~isfield(Out, 'size')
%                 proc = @(x)x; % do nothing
%             else
%                 proc = @(frame) imresize(frame, Out.size);
%             end
%             
%             if ~isfield(Out, 'namefmt')
%                 Out.namefmt = '%04d';
%             end
%             
%             if ~isfield(Out, 'roi')
%                 select = @(x)x;
%             else
%                 select = @(x) (x(Out.roi{1},Out.roi{2},:));
%             end
%             
%             funct = @(frame, index) imwrite( ...
%                 proc(select(frame)), ...
%                 sprintf(Out.namefmt,index) ...
%                 );
%             
%             if ~isfield(Out, 'fps')
%                 foreach_frame_do(video, funct);
%             else
%                 foreach_frame_do(video, funct, Out.fps);
%             end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        end
        
    end
end