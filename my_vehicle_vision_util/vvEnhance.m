classdef vvEnhance
    %% Ref:
    % http://cn.mathworks.com/help/images/examples/contrast-enhancement-techniques.html
    
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
            if nargin < 3
                L = 8;
                if nargin < 2
                    l = 1;
                end
            end
            
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
        function rgbImage2 = brighter(rgbImage)
        % http://www.mathworks.com/matlabcentral/answers/46499-how-to-enhance-a-color-image
            % adjust the brightness without changing color
            hsvImage = rgb2hsv(rgbImage);
            % Extract individual color channels.
            hChannel = hsvImage(:, :, 1);
            sChannel = hsvImage(:, :, 2);
            vChannel = hsvImage(:, :, 3);
            % Do stuff to the v channel.
            vChannel2 = histeq(vChannel);%vvEnhance.SMQT(double(vChannel),1,8);
%             implot(vChannel,vChannel2);
            % Then, after that recombine the new v channel
            % with the old, original h and s channels.
            hsvImage2 = cat(3, hChannel, sChannel, vChannel2);
            % Convert back to rgb.
            rgbImage2 = hsv2rgb(hsvImage2);
        end
        function colorful()
            
        end
    end% methods
end% classdef