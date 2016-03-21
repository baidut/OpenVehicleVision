function plotline(point1, point2, varargin)
xy = [point1; point2];
hold on;
plot(xy(:,1),xy(:,2), varargin{:});

