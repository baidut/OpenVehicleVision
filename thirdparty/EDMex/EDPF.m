function edgeSegments = ED(image, smoothingSigma)

dim = size(image);

temp = EDPFmex(image, dim(1), dim(2), smoothingSigma);

noOfSegments = size(temp, 1) / 2;

edgeSegments = cell(noOfSegments, 1);

for i = 1:noOfSegments
	edgeSegments{i} = zeros(size(temp{i * 2}, 1), 2);
end

for i = 1:noOfSegments
	edgeSegments{i}(:,1) = temp{i * 2 - 1};
	edgeSegments{i}(:,2) = temp{i * 2};
end