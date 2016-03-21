function lineSegments = EDPFLines(image, smoothingSigma)

dim = size(image);

temp = EDPFLinesmex(image, dim(1), dim(2));
noLines = size(temp, 2);

lineSegments = repmat(struct('a', 0, 'b', 0, 'invert', 0, 'sx', 0, 'sy', 0, 'ex', 0, 'ey', 0), noLines, 1);

for i = 1:noLines
	lineSegments(i).a = temp(1,i);
	lineSegments(i).b = temp(2,i);
	lineSegments(i).invert = temp(3,i);
	lineSegments(i).sx = temp(5,i);
	lineSegments(i).sy = temp(4,i);
	lineSegments(i).ex = temp(7,i);
	lineSegments(i).ey = temp(6,i);
end