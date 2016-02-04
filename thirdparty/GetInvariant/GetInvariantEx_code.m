function inv = GetInvariantEx(inputImage,angle,tipus)
%inv = GetInvariantEx(inputImage,angle,tipus)
%
%Computes the invariant image given a RGB image.
%
%
%Road Detection based on Illuminant Invariance
%J.M. Alvarez, A. Lopez
%IEEE ITS, 2011
%
%Combining Appearance, Priors and Context for Road Detection
%J.M. Alvarez, A. Lopez
%IEEE ITS, 2014
%
%Input parameters:
    %inputImage: imatge original
    %
    %angle: Intrinsic parameter of the camera (the invariant direction in
    %       degrees)
    %
    %tipus: Selects the 'norm' method
    %       0 -> (default) The normalization is done using the green (G)
    %       channel
    %       1 -> geometric mean (R*G*B).^(1/3)
%Jose M. Alvarez, 
%jose.alvarez@nicta.com.au

imatge = inputImage;
[sy,sx] = size(imatge);
if  exist('tipus','var')==0,
    tipus = 1;
end
if isfloat(imatge) ~= 1,
    imatge = im2double(imatge);
end

if length(size(imatge)) == 3,
    I = find(imatge==0);
    imatge(I) = eps; 
    if nargin == 2,
        tipus = 0;
    end
    switch tipus, 
        case 0
            invariant = cosd(angle)*log_app(imatge(:,:,1) ./ imatge(:,:,2)) + sind(angle)*log_app(imatge(:,:,3)./imatge(:,:,2));        
        case 1
            GeomMean = (imatge(:,:,1).*imatge(:,:,2).*imatge(:,:,3)).^(1/3)+eps;
            invariant = cosd(angle)*log_app(imatge(:,:,1) ./GeomMean) + sind(angle)*log_app(imatge(:,:,3)./GeomMean);
        case 2
            invariant = cosd(angle)*log_app(imatge(:,:,1) ./ imatge(:,:,2)) + sind(angle)*log_app(imatge(:,:,3)./imatge(:,:,2));     
            invC = -sind(angle)*log_app(imatge(:,:,1) ./ imatge(:,:,2)) + cosd(angle)*log_app(imatge(:,:,3)./imatge(:,:,2));     
    end   
    inv = (invariant);
else
     switch tipus, 
         case 0,
            invariant = cosd(angle)*(imatge(:,1)) + sind(angle)*(imatge(:,2));        
         case 1,
            GeomMean = (imatge(:,1).*imatge(:,2).*imatge(:,3)).^(1/3) + eps;
            invariant = cosd(angle)*log_app(imatge(:,1) ./GeomMean) + sind(angle)*log_app(imatge(:,3)./GeomMean);
         case 2,
            invariant = cosd(angle)*log_app(imatge(:,1) ./ imatge(:,2)) + sind(angle)*log_app(imatge(:,3)./imatge(:,2));        
     end
    inv = (invariant);
end


function lg_x = log_app(x)
%lg_x = log_app(x)
%computes logaritmic approximation
dataSize=  size(x);
x = x(:);
alpha = 5000;
alpha_inv = 1/alpha;
lg_x = alpha .* ( (x.^alpha_inv) -1 );

lg_x = reshape(lg_x,dataSize);