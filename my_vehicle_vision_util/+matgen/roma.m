function roma(path)
% load roma dataset
% load.roma('%datasets/roma');

if nargin < 1
	path = uigetdir;
end

r = RomaDataset(path);

for si = 1:numel(r.situations)
	for sc = 1:numel(r.scenarioMap.keys())
		disp(['load:' si '/' sc])
		roma.(r.situations{si}).(r.scenarioMap.keys(sc)) = r.images(r.situations{si}, r.scenarioMap.values(sc));
	end
end

disp ok