function [edgeSegments, noOfSegments] = ED(image, gradientThreshold, anchorThreshold, smoothingSigma)

dim = size(image);

temp = EDmex(image, dim(1), dim(2), gradientThreshold, anchorThreshold, smoothingSigma);

noOfSegments = size(temp, 1) / 2;

edgeSegments = cell(noOfSegments, 1);

for i = 1:noOfSegments
	edgeSegments{i} = zeros(size(temp{i * 2}, 1), 2);
end

for i = 1:noOfSegments
	edgeSegments{i}(:,1) = temp{i * 2 - 1};
	edgeSegments{i}(:,2) = temp{i * 2};
end