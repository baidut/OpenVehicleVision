classdef LineObj

% point( which row, which column);

    %% Public properties
    properties (GetAccess = public, SetAccess = private)
    	p1, p2 % point 1,2
    	a % angle (-90,90]
    end
 
    %% Public methods
    methods
        function obj = LineObj(endPoint1, endPoint2) % Pi:(ri, ci)
        	obj.p1 = endPoint1;
        	obj.p2 = endPoint2;
        end

        function a = get.a(obj)
        	delta = obj.p1 - obj.p2;
        	k = delta(2)/delta(1); % delta c / delta r
			a = 180*atan(k)/pi;
		end

		function plot(obj, varargin)
			xy = [obj.p1; obj.p2];
			hold on;
			plot(xy(:,2),xy(:,1), varargin{:});
		end
    end% methods
end% classdef

% Football = imread('football.jpg');
% imshow(Football); hold on;
% l = LineObj([10 100], [20 60]);
% l.plot('y');