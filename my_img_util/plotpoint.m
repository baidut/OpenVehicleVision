function h = plotpoint(varargin)
%PLOTOBJ plot points and add remarks.

h = gcf;
c = jet(nargin); % color
name = cell(1,nargin);
handles = zeros(1,nargin);

for i = 1:nargin
	obj = varargin{i};
	name = inputname(i);
	if length(obj) == 2 
		% points
		plot(obj(1), obj(2), 'yo', 'markersize', 10);
global isAnnotate
        if isAnnotate
            text(obj(1)+10, obj(2)-10, ['\color{black}', sprintf([name, '(%.2f, %.2f)'], obj(1), obj(2))]);
        end
    elseif length(size(obj)) == 2 % isbw(obj) Function ISBW has been removed.
		% plot positive points of a binary image.
        [nRow, nCol] = size(obj);
        for r = 1:nRow
            for c = 1 : nCol
                if 1 == obj(r,c)
                    plot(c, r, 'b*'); % 'o' 'color', c(i,:)
                    % Notice the x -> c, y -> r
                end
            end
        end
	else
		error('unexpected inputs.');
	end
end

