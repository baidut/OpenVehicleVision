function [BoundaryL, BoundaryR] = bw2boundaries(BW)
[numRow, numColumn] = size(BW);

Boundary_candidate = zeros(numRow, numColumn);
BoundaryL = zeros(numRow, numColumn);
BoundaryR = zeros(numRow, numColumn);
ScanB = zeros(numRow, numColumn);
ScanL = zeros(numRow, numColumn);
ScanR = zeros(numRow, numColumn);

for c = 1 : numColumn
	for r = numRow : -1 : 1
		if 1 == BW(r, c)
			Boundary_candidate(r, c) = 1;
			break;
		end
		ScanB(r, c) = 1;
	end
end 
for r = numRow : -1 : 1
	for c = ceil(numColumn/2) : -1 : 1
		if 1 == Boundary_candidate(r, c)
			BoundaryL(r, c) = 1;
			break;
		end
		ScanL(r, c) = 1;
	end
	for c = floor(numColumn/2) : numColumn
		if 1 == Boundary_candidate(r, c)
			BoundaryR(r, c) = 1;
			break;
		end
		ScanR(r, c) = 1;
	end
end
