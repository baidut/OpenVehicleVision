function I2 = lensdistort(I, k, varargin)
%LENSDISTORT corrects for barrel and pincusion lens abberations
%   I = LENSDISTORT(I, k)corrects for radially symmetric distortions, where
%   I is the input image and k is the distortion parameter. lens distortion
%   can be one of two types: barrel distortion and pincushion distortion.
%   In "barrel distortion", image magnification decreases with 
%   distance from the optical axis. The apparent effect is that of an image 
%   which has been mapped around a sphere (or barrel). In "pincushion 
%   distortion", image magnification increases with the distance from the 
%   optical axis. The visible effect is that lines that do not go through the 
%   centre of the image are bowed inwards, towards the centre of the image, 
%   like a pincushion [1]. 
%  
%   I = LENSDISTORT(...,PARAM1,VAL1,PARAM2,VAL2,...) creates a new image image, 
%   specifying parameters and corresponding values that control various aspects 
%   of the image distortion correction. Parameter names case does not matter.
%
%   Parameters include:
%
%   'bordertype'            String that controls the treatment of the image
%                           edges. Valid strings are 'fit' and 'crop'. By 
%                           default, 'bordertype' is set to 'crop'. 
%
%   'interpolation'         String that specifies the interpolating kernel 
%                           that the separable resampler uses. Valid
%                           strings are 'cubic', 'linear' and 'nearest'. By
%                           default, the 'interpolation' is set to 'cubic'
%
%   'padmethod'             string that controls how the resampler 
%                           interpolates or assigns values to output elements 
%                           that map close to or outside the edge of the input 
%                           array. Valid strings are 'bound', circular',
%                           'fill', 'replicate', and symmetric'. By
%                           default, the 'padmethod' is set to 'fill'
%
%   'ftype'                 Integer between 1 and 4 that specifies the
%                           distortion model to be used. The models
%                           available are
%
%                           'ftype' = 1:    s = r.*(1./(1+k.*r));
%
%                           'ftype' = 2:    s = r.*(1./(1+k.*(r.^2)));
%
%                           'ftype' = 3:    s = r.*(1+k.*r);
%
%                           'ftype' = 4:    s = r.*(1+k.*(r.^2));
%
%                           By default, the 'ftype' is set to 4.
%   
%   Class Support
%   -------------
%   An input intensity image can be uint8, int8, uint16, int16, uint32,
%   int32, single, double, or logical. An input indexed image can be uint8,
%   uint16, single, double, or logical.
%
%   Examples
%   --------
%       % read image
%       I = imread('cameraman.tif');
%   
%       % Distort Image
%       I2 = lensdistort(I, 0.1);
%
%       % Display both images
%       imshow(I), figure, imshow(I2)
%
%   References
%   --------------
%   [1] http://en.wikipedia.org/wiki/Distortion_(optics), August 2012.
%
%   [2] Harri Ojanen, "Automatic Correction of Lens Distortion by Using
%       Digital Image Processing," July 10, 1999.
%
%   [3] G.Vassy and T.Perlaki, "Applying and removing lens distortion in post 
%       production," year???
% 
%   [4] http://www.mathworks.com/products/demos/image/...
%       create_gallery/tform.html#34594, August 2012.
%      
%   Created by Jaap de Vries, 8/31/2012
%   jpdvrs@yahoo.com
%  
%-----------------------------------------------------------------------%

%-------------------------------------------------------------------------
% This part of the codes creates variable input parameters using the input
% parser object
p = inputParser;
%   Make input string case independant
p.CaseSensitive = false;

%   Specifies the required inputs
addRequired(p,'I',@isnumeric);
addRequired(p,'k',@isnumeric);

%   Sets the default values for the optional parameters
defaultFtype = 4;
defaultBorder = 'crop';
defaultInterpolation = 'cubic';
defaultPadmethod = 'fill';

%   Specifies valid strings for the optional parameters
validBorder = {'fit','crop'};
validInterpolation = {'cubic','linear', 'nearest'};
validPadmethod = {'bound','circular', 'fill', 'replicate', 'symmetric'};

%   Funtion handles to determine wheter a proper input string has been used
checkBorder = @(x) any(validatestring(x,validBorder));
checkInterpolation = @(x) any(validatestring(x,validInterpolation));
checkPadmethod = @(x) any(validatestring(x,validPadmethod));

%   Create optional inputs
addParamValue(p,'bordertype',defaultBorder,checkBorder);
addParamValue(p,'interpolation',defaultInterpolation,checkInterpolation);
addParamValue(p,'padmethod',defaultPadmethod,checkPadmethod);
addParamValue(p,'ftype',defaultFtype,@isnumeric);

%   Pass all parameters and input to the parse method
parse(p,I,k,varargin{:});

%-------------------------------------------------------------------------
% This determines wether its a color (M,N,3) or gray scale (M,N,1) image
if ndims(I) == 3
     for i=1:3
        I2(:,:,i) = imdistcorrect(I(:,:,i),k);
     end   
elseif ismatrix(I)
    I2 = imdistcorrect(I,k);
else
    error('Unknown image dimensions')
end

%-------------------------------------------------------------------------
% Nested function that perfoms the transformation
    function I3 = imdistcorrect(I,k)
    % Determine the size of the image to be distorted
    [M N]=size(I);
    center = [round(N/2) round(M/2)];
    % Creates N x M (#pixels) x-y points
    [xi,yi] = meshgrid(1:N,1:M);
    % Creates converst the mesh into a colum vector of coordiantes relative to
    % the center
    xt = xi(:) - center(1);
    yt = yi(:) - center(2);
    % Converts the x-y coordinates to polar coordinates
    [theta,r] = cart2pol(xt,yt);
    % Calculate the maximum vector (image center to image corner) to be used
    % for normalization
    R = sqrt(center(1)^2 + center(2)^2);
    % Normalize the polar coordinate r to range between 0 and 1 
    r = r/R;
    % Aply the r-based transformation
    s = distortfun(r,k,p.Results.ftype);
    % un-normalize s
    s2 = s * R;
    % Find a scaling parameter based on selected border type  
    brcor = bordercorrect(r,s,k, center, R);
    
    s2 = s2 * brcor;
    
    
    % Convert back to cartesian coordinates
    [ut,vt] = pol2cart(theta,s2);
    
    u = reshape(ut,size(xi)) + center(1);
    v = reshape(vt,size(yi)) + center(2);
    tmap_B = cat(3,u,v);
    resamp = makeresampler(p.Results.interpolation, p.Results.padmethod);
    I3 = tformarray(I,[],resamp,[2 1],[1 2],[],tmap_B,255);
    end

%-------------------------------------------------------------------------
% Nested function that creates a scaling parameter based on the
% 'bordertype' selected
    function x = bordercorrect(r,s,k,center, R)
        if k < 0
            if strcmp(p.Results.bordertype, 'fit')
               x = r(1)/s(1); 
            end
            if strcmp(p.Results.bordertype,'crop')    
               x = 1/(1 + k*(min(center)/R)^2);
            end
        elseif k > 0
            if strcmp(p.Results.bordertype, 'fit')
               x = 1/(1 + k*(min(center)/R)^2);
            end
            if strcmp(p.Results.bordertype, 'crop')    
               x = r(1)/s(1);
            end      
        end
    end

%-------------------------------------------------------------------------
% Nested function that pics the model type to be used
    function s = distortfun(r,k,fcnum)
        switch fcnum
        case(1)
            s = r.*(1./(1+k.*r));
        case(2)
            s = r.*(1./(1+k.*(r.^2)));
        case(3)
            s = r.*(1+k.*r);
        case(4)
            s = r.*(1+k.*(r.^2));
        end
    end


end









