classdef vvBoundModel < handle
    %% VVBOUNDMODEL implements the road bound modeling module of VV lib.
    %
    %   Example
    %   -------
    %   %  Test road segmantation.
    %      colorImage = imread('K:\Documents\MATLAB\dataset\roma\BDXD54\IMG00006.jpg');
    %      Modeling = vvBoundModel(colorImage);
    %      [roadBoundL, roadBoundR] = Modeling.result();
    %
    %   Project website: https://github.com/baidut/openvehiclevision
    %   Copyright 2016 Zhenqiang Ying.
    
    %% Public properties
    properties (GetAccess = public, SetAccess = private)
        rawImg
        VP
    end
    
    %% Public methods
    methods (Access = public)
        
        function model = vvBoundModel(img, vanishingPoint)
            
            model.rawImg = img;
            [rows, cols, chns] = size(img);
            
            if chns ~= 3
                error('color image is needed');
            end
            
            if nargin < 2
                model.VP = [cols/2, rows/3];
            else
                model.VP = vanishingPoint;
            end
            
        end
        
        function [roadBoundL, roadBoundR] = dualStraightLine(model)
            
            nColSplit = floor(model.VP(1));
            nRowSplit = floor(model.VP(2));
            
            roadRoiL = model.rawImg(nRowSplit:end, 1:nColSplit,:);
            roadRoiR = model.rawImg(nRowSplit:end, nColSplit+1:end,:);
            
            roadBoundL = model.straightLine(roadRoiL, true);
            roadBoundR = model.straightLine(roadRoiR, false);
            
            % move bound line to raw image xy
        end
    end
    
    methods(Static)
        function bound = straightLine(imgRoi, isleft)
            %% Road Bound Straight Line Modeling Pipeline
            imgRoi = vvPreproc.deblock(imgRoi);
            boundFeature = vvFeature.S2(imgRoi);
            boundRegion = vvThresh.otsu(boundFeature);
            boundRegion = vvPostproc.filterBw(boundRegion);
            
            boundPoints = vvBoundModel.boundPoints(boundRegion, isleft);
            
            boundAngleMin = 30;
            boundAngleMax = 75;
            if isleft
                bound = vvBoundModel.houghStraightLine(boundPoints, boundAngleMin:boundAngleMax); % 0:89
            else
                bound = vvBoundModel.houghStraightLine(boundPoints, -boundAngleMax:-boundAngleMin); % -89:0
            end
        end
        
        function Boundary = boundPoints(BW, isleft)
            [nRow, nCol] = size(BW);
            Candidate = zeros(nRow, nCol);
            Boundary = zeros(nRow, nCol);
            
            % do filtering first
            BW(uint8(end*5/6):end,:) = 0;
            
            for c = 1 : nCol % for each column
                r = find(BW(:,c),1,'last');% up-down scan
                Candidate(r, c) = 1;
            end
            
            if isleft
                for r = 1 : nRow
                    c = find(Candidate(r,:),1,'last');
                    Boundary(r, c) = 1;
                end
            else
                for r = 1 : nRow
                    c = find(Candidate(r,:),1,'first');
                    Boundary(r, c) = 1;
                end
            end
            
            Boundary(uint8(end*5/6-1),:) = 0;
        end
        
        function line = houghStraightLine(BW, Theta)
            %Hough Transform
            [H,theta,rho] = hough(BW, 'Theta', Theta);
            
            % Finding the Hough peaks
            P = houghpeaks(H, 1);
            %x = theta(P(:,2));
            %y = rho(P(:,1));
            
            %Fill the gaps of Edges and set the Minimum length of a line
            lines = houghlines(BW,theta,rho,P, 'MinLength',10, 'FillGap',570);
            
            if length(lines) > 1
                lines = lines(1);
            end
            
            if length(lines) ~= 1
                disp('Fail in fitLine.');
                line = [];
                return;
            end
            
            % line = LineObj([lines.point1(2), lines.point1(1)], [lines.point2(2), lines.point2(1)]);
            line = LineObj(lines.point1, lines.point2);
            if nargout == 0
                line.plot();
            end
        end
        
        function line = ransacStraightLine(BW)
            [X,Y] = find(BW == 1);
            pts = [X';Y'];
            iterNum = 300;
            thDist = 2;
            thInlrRatio = .1;
            [t,r] = ransac(pts,iterNum,thDist,thInlrRatio);
            k1 = -tan(t);
            b1 = r/cos(t);
            Y = k1*X+b1;
            line = LineObj([X(1), Y(1)], [X(end), Y(end)]);
        end
    end
end% classdef