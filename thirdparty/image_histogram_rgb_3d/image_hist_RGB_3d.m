function [freq, freq_emph, freq_app] = image_hist_RGB_3d(imname,n,gamma)

% Creates 3D-histogram from an RGB image
% in the form of balls in the RGB cube
%
% Input:
%  IMNAME......Name of the image file in RGB 24bpp
%  N...........Number of histogram bins within each axis;
%              if undefined, the default value is taken N = 6
%  GAMMA.......Power value used for emphasizing small frequencies:
%              out = out.^GAMMA;
%              GAMMA = 1 means no change.
%              If undefined, the default value is GAMMA = 0.5.
%              If GAMMA is set to 0, the "emphasizing" is done so that
%              empty cells will remain at zero and the rest will contain 1.
% 
% Output:
%  FREQ.........Frequencies arranged in the 3D matrix. The resultant values 
%               can be also non-integral (due to a compensation which is
%               done if the cells ranges differ).
%  FREQ_EMPH....Emphasized values of FREQ, dependent on GAMMA
%  FREQ_APP.....Frequencies (without emphasizing) arranged in the 3D matrix,
%               layers arranged according to the initial appearance of the histogram
%               FREQ_APP(i,j,k) :
%               (R increases with j, G increases with k, B increases with i)
%
% Example:
%  [freq, freq_emph, freq_app] = image_hist_RGB_3d('image.jpg',5,0.6);

% (c) 2012 Jan Zatyik, Pavel Rajmic,
% Brno University of Technology, Czech Republic
% version 1.25
% www.splab.cz

% Last revision: October 19, 2012

% Credits: inspired by
% http://ij-plugins.sourceforge.net/ij-vtk/color-space/index.html




%% Checking the input arguments
if nargin <= 2 
    gamma = 0.5;
end
if nargin == 1
    n = 6;
end
if n == 1
    error('it is nonsense to use n=1');
end

%% Reading the image
disp('Starting...')
disp('Reading the image...');

im = imread(imname);    % loading the image
s = size(im);
im = double(im);

%% Assigning the pixels to the histogram cells
disp('Assigning the pixels to the histogram cells...');
step = 255/n;
cell_no = ceil(im/step); % numbers of cells for all pixels
% cell_no can be computed as 0, so we assing them to the first cell
cell_no(cell_no==0) = 1; 


%% Computing the frequencies
disp('Computing the frequencies...');
% initialization of vector, which will be used for saving the frequencies
freq = zeros(n^3,1); 

% computing to which index belong the data
a = cell_no(:,:,1) - 1;
b = cell_no(:,:,2) - 1;
c = cell_no(:,:,3) - 1;
index = n * a +n^2 *b + c + 1;

% computation of frequencies
for col = 1:s(2)
    for row = 1:s(1)
        freq(index(row,col)) = freq(index(row,col)) + 1;
    end
end
% Reshaping into 3D-array
freq = reshape(freq,n,n,n);


%% Compensation due to (possible) non-uniform length of cells
bound = linspace(0,255,n+1); %where are the cell boundaries
bound_int = floor(bound); %integers
% averages (used later during plotting)
cell_avrg = cumsum(diff(bound)) - (255/n)/2;
cell_avrg_int = round(cell_avrg);

% how many values can the cells contain
% (these values can differ by 1 or will be the same)
cell_ranges = diff(bound_int);
maxmin_ratio = max(cell_ranges) / min(cell_ranges);
% determining which cells are to be compensated
cells_to_compensate = find(cell_ranges - min(cell_ranges)); %nonzero elements
% calculate the compensated frequencies (rows(R), columns(G), slides(B))
freq(cells_to_compensate,:,:) = freq(cells_to_compensate,:,:) / maxmin_ratio;
freq(:,cells_to_compensate,:) = freq(:,cells_to_compensate,:) / maxmin_ratio;
freq(:,:,cells_to_compensate) = freq(:,:,cells_to_compensate) / maxmin_ratio;


%% Emphasizing small frequencies by gamma
maxfreq = max(max(max(freq))); %maximum frequency
if gamma ~=1
    disp(['Recalculating frequencies by means of gamma=' num2str(gamma) ' ...'])
    if gamma == 0
        disp('!!! Warning: GAMMA is zero!');
        freq_emph = zeros(size(freq)); %zeros everywhere
        freq_emph(freq~=0) = 1; %ones; the same result as if .^0 was computed
        maxfreq = 1;
    else
        freq_emph = freq / maxfreq;   %first, normalize to [0,1]
        freq_emph = freq_emph.^gamma; %second, emphasize
        freq_emph = freq_emph * maxfreq; %finally, un-normalize
        %maximum frequency remains unchanged
    end
else
    freq_emph = freq; %no change
end


%% Drawing the histogram
disp('Drawing the histogram...')
figure
% whitebg([0.9 0.9 0.9])   
maxradius = 255/n;
[Rss Gss Bss] = sphere(16); % mesh for unit sphere
% resizing the sphere to maximum
Rss = Rss * maxradius/2; 
Gss = Gss * maxradius/2;
Bss = Bss * maxradius/2;

% loop over all histogram cells and plot the balls
for cnt_B = 1:n
    for cnt_G = 1:n
        for cnt_R = 1:n
            RGBfreq = freq_emph(cnt_B, cnt_R, cnt_G); %scalar
            if RGBfreq ~= 0 % if a sphere has to appear
                % begin with the initial sphere
                Rs = Rss;
                Gs = Gss;
                Bs = Bss;
                % size of the sphere according to the frequency
                ratio = RGBfreq / maxfreq;
                Rs = Rs * ratio;
                Gs = Gs * ratio;
                Bs = Bs * ratio;
                % translation the sphere to the right place
                modR = mod(cnt_R-1,n);
                modG = mod(cnt_G-1,n);
                modB = mod(cnt_B-1,n);
                Rs = Rs + (modR+0.5) * maxradius;
                Gs = Gs + (modG+0.5) * maxradius;
                Bs = Bs + (modB+0.5) * maxradius;
                % drawing
                h = surf(Rs,Gs,Bs);
                % coloring the sphere by the color taken from the center of the respective cube
                colorR = cell_avrg_int(modR+1);
                colorG = cell_avrg_int(modG+1);
                colorB = cell_avrg_int(modB+1);
                set(h,'EdgeColor','none', ...
                    'FaceColor',[ colorR colorG colorB ]/255, ...
                    'FaceLighting','phong', ...
                    'AmbientStrength',0.7, ...
                    'DiffuseStrength',0.4, ...
                    'SpecularStrength',0.4, ...
                    'SpecularExponent',500, ...
                    'BackFaceLighting','reverselit');
                hold on
                hidden off
            end
        end
    end
end

% visualization parameters
set(gca, 'XColor', 'r','YColor', 'g', 'ZColor', 'b');
%set(gca, 'XColor', 'r','YColor', [0 0.7 0], 'ZColor', 'b');
set(gcf, 'color', 'none');
set(gca, 'color', 'none');
axis([ 0 255 0 255 0 255]);
xlabel('R');
ylabel('G');
zlabel('B');
camlight(14,36);
rotate3d on 
view(14,36)
axis square

%% Compute FREQ_APP
if nargout>2
    disp('Rearranging frequencies into the structure as appeared in the figure...')
    freq_app = zeros(n,n,n);
    for w = 1:n
        freq_app(:,:,w) = (flipud((freq(:,:,w))));
    end
end

%% End
disp('Finished.')