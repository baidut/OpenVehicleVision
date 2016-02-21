classdef vvEnhance
%% Ref:
% IMAGE ENHANCEMENT WITH MATLAB ALGORITHMS
% http://www.diva-portal.se/smash/get/diva2:817007/FULLTEXT01.pdf
    %% Static methods
    methods (Static)
%% SMQT Matlab Code (THE SUCCESSIVE MEAN QUANTIZATION TRANSFORM)
        % http://stackoverflow.com/questions/24385880/smqt-matlab-code-the-successive-mean-quantization-transform
        function M = SMQT(V, l, L)
% USAGE:     
% I = imread('cameraman.tif');
% M = uint8(vvEnhance.SMQT(double(I),1,8));
% imshow(M);
            if l>L
                M = zeros(size(V), 'like', V);
                return;
            end
            meanV = nanmean(V(:));
            D0 = V;
            D1 = V;
            if not(isnan(meanV))
                D0(D0 > meanV) = NaN;
                D1(D1 <= meanV) = NaN;
            end
            M = not(isnan(D1)) * (2^(L-l));
            if l==L
                return;
            end
            M0 = vvEnhance.SMQT(D0, l+1, L);
            M1 = vvEnhance.SMQT(D1, l+1, L);
            M = M + M0 + M1;
        end
    end% methods
end% classdef