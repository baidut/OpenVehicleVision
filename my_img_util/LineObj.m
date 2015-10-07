classdef LineObj<handle
% point( which row, which column);

    %% Public properties
    properties
        p1, p2 % point 1,2
        a % angle (-90,90]
        k % ratio of delta c to delta r
    end
 
    %% Public methods
    methods
        function obj = LineObj(endPoint1, endPoint2) % Pi:(ci, ri) Notice!
            obj.p1 = endPoint1;
            obj.p2 = endPoint2;
        end

        function a = get.a(obj)
            a = 180*atan(obj.k)/pi;
        end
        
        function t = theta(obj)
            t = - obj.a;
        end

        function k = get.k(obj)
            delta = obj.p1 - obj.p2;
            k = delta(1)/delta(2); % delta c / delta r
        end

        function h = plot(obj, varargin)
            xy = [obj.p1; obj.p2];
            hold on;
            h = plot(xy(:,1),xy(:,2), varargin{:});
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
                C = obj.k*(R-obj.p1(2))+obj.p1(1);
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
            bool = abs( (point(1)-obj.p1(1))/(point(2)-obj.p1(2)) - obj.k ) < err;
        end

        function c = row(obj, r)
            c = obj.p1(1) + obj.k*(r -obj.p1(2));
        end

       function point = PointAtRow(obj, r)
            point = [obj.p1(1) + obj.k*(r -obj.p1(2)), r];
        end

        function point = cross(obj, line2)
        % compute the intersection point with another lineObj.

            X1 = obj.p1;
            Y1 = obj.p2;

            X2 = line2.p1;
            Y2 = line2.p2;

            if X1(1)==Y1(1)
                X=X1(1);
                k2=(Y2(2)-X2(2))/(Y2(1)-X2(1));
                b2=X2(2)-k2*X2(1); 
                Y=k2*X+b2;
            end
            if X2(1)==Y2(1)
                X=X2(1);
                k1=(Y1(2)-X1(2))/(Y1(1)-X1(1));
                b1=X1(2)-k1*X1(1);
                Y=k1*X+b1;
            end
            if X1(1)~=Y1(1)&X2(1)~=Y2(1)
                k1=(Y1(2)-X1(2))/(Y1(1)-X1(1));
                k2=(Y2(2)-X2(2))/(Y2(1)-X2(1));
                b1=X1(2)-k1*X1(1);
                b2=X2(2)-k2*X2(1);
                if k1==k2
                   X=[];
                   Y=[];
                else
                X=(b2-b1)/(k1-k2);
                Y=k1*X+b1;
                end
            end
            point = [X Y];
        end
    end% methods
end% classdef

% Football = imread('football.jpg');
% imshow(Football); hold on;
% l = LineObj([10 100], [20 60]);
% l.plot('y');