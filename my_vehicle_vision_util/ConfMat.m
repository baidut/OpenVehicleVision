classdef ConfMat < handle
    % Confusion Matrix
    %{
    % eg.1 Single Image
    imgFile = '%datasets\roma\BDXD54\IMG00164.jpg'; % IMG00106 IMG00002 IMG00164
    rawImg = imread(imgFile);
    gtImg = imread(RomaDataset.roadAreaGt(imgFile));
    
    roiOf = @(x)x(ceil(end/2):end,:,:);
    roiImg = roiOf(rawImg);
    gt = roiOf(gtImg);
    
    result = road_detection_via_ii(roiImg,0.2*255);
    
    eval = ConfMat({result},{gt},1);
    imshow(roiImg/3+eval.mask{1});
    disp(eval);
    
    % eg.2 Image Dataset
    imgFile = foreach_file_do('%datasets\roma\BDXD54\*.jpg',@(x)x);
    rawImg = foreach_file_do('%datasets\roma\BDXD54\*.jpg',@imread);
    gtImg = foreach_file_do('%datasets\roma\BDXD54\*.png',@imread);
    
    roiOf = @(x)x(ceil(end/2):end,:,:);
    roiImg = cellfun(roiOf,rawImg,'UniformOutput',false);
    gt = cellfun(roiOf,gtImg,'UniformOutput',false);
    
    f = @(im)road_detection_via_ii(im,0.2*255);
    result = cellfun(f,roiImg,'UniformOutput',false);
    
    eval = ConfMat(result,gt);
    disp(eval);
    vis(eval,roiImg);
    
    %}
    properties (GetAccess = public, SetAccess = private)
        TP,FP
        FN,TN
        
        mask % for visualization
    end
    
    methods (Static)
        function [TP,FP,TN,FN,mask] = compute(result, GT, label)
            % Note TP... is not a ratio but a count number about
            % how many true positive pixels in image or images.
            % 2 class problem
            TP_bw = (result == label) & (GT == label);
            FP_bw = (result == label) & (GT ~= label);
            TN_bw = (result ~= label) & (GT ~= label);
            FN_bw = (result ~= label) & (GT == label);
            
            TP = sum(TP_bw(:));
            FP = sum(FP_bw(:));
            TN = sum(TN_bw(:));
            FN = sum(FN_bw(:));
            % red denotes false negatives, blue areas correspond to
            % false positives and green represents true positives.
            % FP and FN need to be transparent for finding the
            % possible reason.
            % ------------------ R ---------- G ------- B -----
            mask = uint8(cat(3,FN_bw*128,TP_bw*255,FP_bw*128));
        end
    end
    
    methods (Access = public)
        function eval = ConfMat(results, GTs, label)
            if nargin < 3
                label = 1;
            end
            
            func = @(res,gt) ConfMat.compute(res,gt,label);
            
            [cTP,cFP,cTN,cFN,eval.mask] = ...
                cellfun(func,results,GTs,'UniformOutput',false);
            
            eval.TP = cell2mat(cTP);
            eval.FP = cell2mat(cFP);
            eval.TN = cell2mat(cTN);
            eval.FN = cell2mat(cFN);
        end
        
        function MaskedImgs = vis(eval, rawImgs)
        % visualize
            disp_method = @(raw,mask)(raw/3+mask);

            MaskedImgs = cellfun(disp_method,rawImgs,eval.mask,'UniformOutput',false);
            
%             cell2mat(arrayfun(@(x,y)disp_method(x{:},y{:}), ...
%             num2cell(rawImgs,1:3),num2cell(eval.mask,1:3),...
%             'UniformOutput', false));
            if nargout == 0
                implay(cat(4, MaskedImgs{:}));
            end
        end
    end
    
    methods (Access = public)
        function ACC = accuracy(eval)
            ACC = (eval.TP + eval.TN) ./ (eval.TP + eval.TN + eval.FP + eval.FN);
        end
        
        function PRE = precision(eval)
            PRE = eval.TP ./ (eval.TP + eval.FP);
        end
        
        function REC = recall(eval)
            REC = eval.TP ./ (eval.TP + eval.FN);
        end
        
        function FPR = fallout(eval)
            % fall-out or false positive rate (FPR)
            FPR = eval.FP ./ (eval.FP + eval.TN);
        end
        
        function FNR = missrate(eval)
            % miss rate or false negative rate (FNR)
            FNR = eval.FN ./ (eval.FN + eval.TP);
        end
        
        function disp(eval)
            % evaluation report
            builtin('disp',eval);
            if isempty(eval), return; end
            
            ACC = eval.accuracy;
            PRE = eval.precision;
            REC = eval.recall;
            FPR = eval.fallout;
            FNR = eval.missrate;
            
            T = table(ACC,...
                PRE,REC,...
                FPR,FNR...
                );
            disp(T);
        end
    end
  
end