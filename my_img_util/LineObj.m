classdef LineObj<handle
% How to modify properties of a Matlab Object http://stackoverflow.com/questions/272618/how-to-modify-properties-of-a-matlab-object
% OR l = l.move([r, c])

% point( which row, which column);

    %% Public properties
    properties
        p1, p2 % point 1,2
        a % angle (-90,90]
        k % ratio of delta c to delta r
    end
 
    %% Public methods
    methods
        function obj = LineObj(endPoint1, endPoint2) % Pi:(ri, ci)
            obj.p1 = endPoint1;
            obj.p2 = endPoint2;
        end

        function a = get.a(obj)
            a = 180*atan(obj.k)/pi;
        end

        function k = get.k(obj)
            delta = obj.p1 - obj.p2;
            k = delta(2)/delta(1); % delta c / delta r
        end

        function h = plot(obj, varargin)
            xy = [obj.p1; obj.p2];
            hold on;
            h = plot(xy(:,2),xy(:,1), varargin{:});
        end

        function move(obj, vector) % translation
            obj.p1 = obj.p1 + vector; 
            obj.p2 = obj.p2 + vector; 
        end

        function bw = path(obj, sizeOfImage, sizeOfGrid)
        % generates the path of walking along the straight line at a gridded image
            bw = zeros(sizeOfGrid);
            for r = 1:sizeOfGrid(1)
                R = r * sizeOfImage(1) / sizeOfGrid(1);
                C = obj.k*(R-obj.p1(1))+obj.p1(2);
                c = round(C * sizeOfGrid(2) / sizeOfImage(2));
                if (c>1) && (c<sizeOfGrid(2))
                    bw(r,c) = 1;
                end
            end
        end

        function d = distance2point(obj, point)
            d = abs(det([obj.p2-obj.p1 ; point-obj.p1])) / norm(obj.p2-obj.p1);
        end

        function bool = pass(obj, point, err)
        % check if the line pass given point.
            bool = abs( (point(2)-obj.p1(2))/(point(1)-obj.p1(1)) - obj.k ) < err;
        end
    end% methods
end% classdef

% Football = imread('football.jpg');
% imshow(Football); hold on;
% l = LineObj([10 100], [20 60]);
% l.plot('y');