function meshCanopy(I,Mdata,Mmap,height)
%function meshCanopy: display a mesh above a grayscale image
%SCd 11/18/2010
%
%Updates:
%   -11/22/2010: Added example (requires IPT)
%                Added height input argument
%
%Input Arguments:
%   -I: 2-dimensional grayscale image slice.  The values are expected to
%       range from 0 to 255.  If the maximum value is greater than 255 or
%       the minimum value is less than 0, it will be scaled to 0:255.  Else
%       it will remain unchanged.
%   -Mdata: 2-dimensional mesh data (Z for a meshplot).
%       NOTE: the mesh command will be called with:
%       >>[ii jj] = meshgrid(ceil(cumsum(diff([0 linspace(1,size(I,2),size(Mdata,2))]))),ceil(cumsum(diff([0 linspace(1,size(I,1),size(Mdata,1))]))));
%       >>mesh(ii,jj,Mdata);
%       and thus does not need to be the same size as the image!
%   -Mmap: string, function_handle or nx3, mesh color map.  See:
%       >>doc colormap 
%       for valid options.  The argument is optional and defaults to 'jet'
%       Examples: 'jet', @jet, [0 0 1; 0.5 0;.1 .1 .1]
%   -height: scalar height of the mesh above the image so you can see both. 
%       Optional defaults to 80.
%
%Output Arguments:
%   -None!
%
%Example: (Requires the Image Processing Toolbox)
%   %Display a Mesh Canopy of a standard deviation image, above the original image
%   I = imread('cameraman.tif');
%   M = stdfilt(I);
%   meshCanopy(I,M,@spring)
%
%See also: mesh colormap
%

%Error Checking:
assert(nargin==2||nargin==3||nargin==4,'The number of input arguments is expected to be 2, 3 or 4.\n  It was %i',nargin);
assert(ndims(I)==2,'The first input argument, I, is required to be 2-dimensional');
assert(ndims(Mdata)==2,'The second input argument, Mdata, is required to be 2-dimensional');

%Assigning and checking the mesh colormap/height
if nargin == 2
    Cmap = [gray(256); jet(256)]; %Default
elseif ischar(Mmap)
    %String is used, assert it's right.
    valid_maps = {'jet','hsv','hot','cool','spring','summer','autumn','winter','gray','bone','copper','pink','lines'};
    assert(any(ismember(valid_maps,Mmap)),'If a string is used as a colormap, it is expected to match one of these:\n%s',sprintf('%s\n',valid_maps{:}));
    Mmap = str2func(Mmap);
    Cmap = [gray(256); Mmap(256)];
elseif isa(Mmap,'function_handle')
    %Function handle is user, assert it's right
    valid_maps = {'jet','hsv','hot','cool','spring','summer','autumn','winter','gray','bone','copper','pink','lines'};
    assert(any(ismember(valid_maps,func2str(Mmap))),'If a function_handle is used as a colormap, it is expected to match one of these:\n%s',sprintf('%s\n',valid_maps{:}));
    Cmap = [gray(256); Mmap(256)];
else    
    %Explicit color map is used, make sure it's ok
    assert(size(Mmap,2)==3,'If a matrix colormap is used the second dimension must be 3');
    assert(all(Mmap(:)<=1&Mmap(:)>=0),'If a matrix colormap is used the values must all: 0 <= Mmap <= 1');
    Cmap = [gray(256); Mmap];
end
if ~exist('height','var');
    height = 80;
else
    assert(isscalar(height),'The fourth argument, height, is expected to be a scalar');
end
    
%Making required pieces
I = double(I); %Needs to be double for slice() and all other calculations
Mdata = double(Mdata);
[ii jj] = meshgrid(ceil(cumsum(diff([0 linspace(1,size(I,2),size(Mdata,2))]))),ceil(cumsum(diff([0 linspace(1,size(I,1),size(Mdata,1))]))));

Mdata = (Mdata - min(Mdata(:)))+height; %Scale so minimum is height (so it doesn't conflict with image)
Midx = ceil(min((length(Cmap)-256),round((length(Cmap)-255)*(Mdata-min(Mdata(:)))/(max(Mdata(:))-min(Mdata(:))))+1))+256;

if any(I(:)<0)||any(I(:)>255)
    %Scale whole image to 1:256 for the map (only if it was out of bounds before!
    I = ceil(min(256,round((255)*(I-min(I(:)))/(max(I(:))-min(I(:))))+1));
else
    %Else adjust to 1:256 integer increment
    I = ceil(I+1);
end

%Plotting7
figure;
H(1) = slice(repmat(I,[1 1 2]),[],[],1); %slice() requires at least 2x2x2
set(H(1),'EdgeColor','none') %required so image isn't just an edge
hold on
H(2) = mesh(ii,jj,double(Mdata));
hold off

%Plot Properties
axis vis3d
axis ij
axis tight
colormap(Cmap)
set(H(1),'CData',I);
set(H(2),'CData',Midx);
caxis([1 length(Cmap)])
