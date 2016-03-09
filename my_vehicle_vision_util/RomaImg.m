% road_im = RomaImg('%datasets\roma\RouenN8IRC052310\IMG01339.jpg');
% imshow(road_im.groundTruth);

classdef RomaImg < RawImg

    methods (Access = public)
        function I = RomaImg(file)
            I@RawImg(file);
        end
        function GT = groundTruth(I)
            GT = RomaGtImg([I.path,'/R',I.name,'.pgm']);
        end
    end
end
