function res = road_detection_via_ii_felzen(rawImg, ii_method, ii_params, debug)

if nargin < 4
    debug = false;
end

%% Illumination Invariant Imaging 
% RGB --> II
iiImg =  ii_method(rawImg, ii_params{:});
ii = repmat(im2uint8(iiImg), [1 1 3]);
label = vvSeg.felzen(ii, 1.5,600,1000);

RoadFace = label.maxarea();
Fig.subimshow(rgb, RoadFace);
res = RoadFace.data;

%% Debug
if debug

end

end
