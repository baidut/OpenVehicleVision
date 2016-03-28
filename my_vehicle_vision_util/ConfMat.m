classdef ConfMat < handle
    % Confusion Matrix
%{
    imgFile = '%datasets\roma\BDXD54\IMG00002.jpg';
    rawImg = imread(imgFile);
    result = road_detection_via_ii(imgFile,0.2*255);
    GT = imread(RomaDataset.roadAreaGt(imgFile));
    eval = ConfMat(result,GT,1);
    imshow(rawImg/3+eval.visualizeMask);
    disp(eval);
%}
    properties (GetAccess = public, SetAccess = private)
        TP,FP
        FN,TN
        
        visualizeMask
    end
    
    methods (Access = public)
        function eval = ConfMat(result, GT, label)
            % Note TP... is not a ratio but a count number about
            % how many true positive pixels in image or images.
            % 2 class problem
            TP_bw = (result == label) & (GT == label);
            FP_bw = (result == label) & (GT ~= label);
            TN_bw = (result ~= label) & (GT ~= label);
            FN_bw = (result ~= label) & (GT == label);
            
            eval.TP = sum(TP_bw(:));
            eval.FP = sum(FP_bw(:));
            eval.TN = sum(TN_bw(:));
            eval.FN = sum(FN_bw(:));
            % red denotes false negatives, blue areas correspond to
            % false positives and green represents true positives.
            % FP and FN need to be transparent for finding the
            % possible reason.
            % -------------------------- R ---------- G ------- B -----
            eval.visualizeMask = uint8(cat(3,FN_bw*128,TP_bw*255,FP_bw*128));
        end
        
        function ACC = accuracy(eval)
            ACC = (eval.TP + eval.TN) / (eval.TP + eval.TN + eval.FP + eval.FN); 
        end
        
        function PRE = precision(eval)
            PRE = eval.TP / (eval.TP + eval.FP);
        end
        
        function REC = recall(eval)
            REC = eval.TP / (eval.TP + eval.FN);
        end
        
        function FPR = fallout(eval)
        % fall-out or false positive rate (FPR)
            FPR = eval.FP / (eval.FP + eval.TN); 
        end
        
        function FNR = missrate(eval)
        % miss rate or false negative rate (FNR)
            FNR = eval.FN / (eval.FN + eval.TP);
        end
        
        function disp(eval)
            % evaluation report
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
    
    
    methods (Static)
    end
    
end