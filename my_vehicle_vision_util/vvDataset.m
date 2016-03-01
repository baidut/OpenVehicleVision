classdef vvDataset<handle
    %VVDATASET handles the dataset related things.
    %
    %   Project website: https://github.com/baidut/openvehiclevision
    %   Copyright 2016 Zhenqiang Ying.
    
    properties
        path
        %sub % subdataset N*1 cell
        %curDataset
        selected % selected files
        gt
    end
    %Example
    %{
%After-Rain/ After-Rain\
AfterRain = vvDataset('%datasets\nicta-RoadImageDatabase\After-Rain');

files = AfterRain.filenames('*.tif');
montage(files(1:8:end));

AfterRain.select('*.tif');
implay(AfterRain); % montage(AfterRain);

RawImgs = AfterRain.imgsarray('*.tif');
GtImgs = AfterRain.imgsarray('*.png');
RgbGtImgs = repmat(GtImgs, [1, 1, 3]);% gray to rgb
    
implay([RawImgs RgbGtImgs]);

    
% matlab code %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load raw image
d = dir('%datasets\nicta-RoadImageDatabase\After-Rain\*.tif');
% fileparts
nameFolds = {d.name}';
imgfiles = strcat('%datasets\nicta-RoadImageDatabase\After-Rain\',nameFolds);
% montage(imgfiles); % all images
montage(imgfiles(1:8:end)); % every eight images

% imread
imgscell = cellfun(@imread,imgfiles,'UniformOutput',false);
% M-by-N-by-3-by-K array.
t = reshape([imgscell{:}], [480 640 481 3]); % M-N*K-3 to M-N-K-3
imgsarray = permute(t,[1 2 4 3]); % 1 2 3 4 to 1 2 4 3 M-N-3-K
implay(imgsarray);
    %}
    methods (Access = public)
        function obj = vvDataset(path)
            obj.path = path;
%             obj.sub = subfolder(path);
            
        end
        
        function selected = select(obj,selector)
            obj.selected = obj.filenames(selector);
            selected = obj.selected;
        end
        function files = filenames(obj,selector)
            d = dir(fullfile(obj.path,selector));
            nameFolds = {d.name}';
            files = strcat([obj.path '/'],nameFolds);
        end
        
        function a = imgsarray(obj, selector)
            if nargin < 2
                files = obj.selected;
            else
                files = obj.select(selector);
            end
            nfiles = numel(files);
            [nRows, nCols, nChns] = size(imread(files{1}));
            
            imgscell = cellfun(@imread,files,'UniformOutput',false);
            % M-by-N-by-3-by-K array.
            t = reshape([imgscell{:}], [nRows nCols nfiles nChns]); % M-N*K-3 to M-N-K-3
            a = permute(t,[1 2 4 3]); % 1 2 3 4 to 1 2 4 3
        end
        
        function montage(obj, varargin)
            montage(obj.selected, varargin{:});
        end
        function implay(obj, varargin)
            implay(obj.imgsarray(),varargin{:});
        end
        %         function select(obj, n)
        %             % select subdataset
        %             obj.curDataset = n;
        %         end
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
            disp(vidObj); % show video message.
            
            %% load default settings
            if ~isfield(Out, 'namefmt')
                Out.namefmt = '%04d';
            end
            
            if ~isfield(Out, 'fps')
                Out.fps = vidObj.FrameRate;
            end
            
            %             if ~isfield(Out, 'roi')
            %                 Out.roi = {1:vidObj.Height,1:vidObj.Width };
            %             end
            %
            %             if ~isfield(Out, 'size')
            %                 Out.size = [vidObj.Height, vidObj.Width];
            %             end
            
            do_roi = isfield(Out, 'roi');
            do_resize = isfield(Out, 'size');
            
            for n = 1 : vidObj.FrameRate/Out.fps : vidObj.NumberOfFrames
                idx = uint32(round(n));
                vidFrame = read(vidObj, idx);
                
                %                 roi = vidFrame(Out.roi{1},Out.roi{2},:);
                %                 resized = imresize(roi, Out.size);
                %                 imwrite( resized, sprintf(Out.namefmt,idx) );
                if do_roi
                    vidFrame = vidFrame(Out.roi{1},Out.roi{2},:);
                end
                if do_resize
                    vidFrame = imresize(vidFrame, Out.size);
                end
                imwrite( vidFrame, sprintf(Out.namefmt,idx) );
                
                fprintf(['%2d%% done:' Out.namefmt '\n'],floor(100*n/vidObj.NumberOfFrames),idx);
            end
            
            disp('ok');
            disp(vidObj);
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