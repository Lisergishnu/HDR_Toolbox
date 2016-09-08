function [stack, stack_exposure] = CreateLDRStackFromHDR( img, fstopDistance, geb_mode, lin_type, lin_fun)
%
%
%       stack = CreateLDRStackFromHDR( img )
%       
%
%        Input:
%           -img: input HDR image
%           -fstopDistance: delta f-stop for generating exposures
%           -geb_mode: how to samples the image:
%                  - if geb_mode = 'uniform', exposures are sampled
%                    in an uniform way
%                  - if geb_mode = 'histogram', exposures are sampled using
%                    the histogram using a greedy approach
%                  - if geb_mode = 'selected', we assume that fstopDistance
%                  is an array with the f-stops selected
%
%           -lin_type: the linearization function:
%                      - 'linear': images are already linear
%                      - 'gamma': gamma function is used for linearization;
%                      - 'sRGB': images are encoded using sRGB
%                      - 'LUT': the lineraziation function is a look-up
%                               table defined stored as an array in the 
%                               lin_fun 
%                      - 'poly': the lineraziation function is a polynomial
%                               stored in lin_fun
%
%           -lin_fun: it is the camera response function data of the camera 
%           that took the pictures in the stack. Depending on lin_type:
%                   - 'gamma': this is a single value; i.e. the gamma
%                   value.
%                   - 'sRGB': this value is empty or can be omitted
%                   - 'linear': this value can be empty or can be omitted
%                   - 'LUT': this value has to be a $n \times col$ array 
%                   - 'poly': this values has to be a $n \times col$ array
%                   that encodes a polynomial 
%
%        Output:
%           -stack: a stack of LDR images
%           -stack_exposure: exposure values of the stack (stored as time
%           in seconds)
% 
%     Copyright (C) 2016 Francesco Banterle
%  
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

[r,c,col] = size(img);

if(~exist('fstopDistance', 'var'))
    fstopDistance = 1;
end

if(~exist('geb_mode', 'var'))
    geb_mode = 'histogram';
end

%is the linearization type of the images defined?
if(~exist('lin_type', 'var'))
    lin_type = 'gamma';
end

%do we have the inverse camera response function?
if(~exist('lin_fun', 'var'))
    lin_fun = 2.2;
end

%luminance channel
L = lum(img);

switch(geb_mode)
    case 'histogram'
        stack_exposure = 2.^ExposureHistogramCovering(img);
        
    case 'uniform'
        MinL = MaxQuart(L(L > 0.0), 0.01);
        MaxL = MaxQuart(L(L > 0.0), 0.9999);

        minExposure = floor(log2(MaxL));
        maxExposure = ceil( log2(MinL));

        tMax = -(maxExposure - 1);
        tMin = -(minExposure + 1);
        stack_exposure = 2.^(tMin:fstopDistance:tMax);
        
    case 'selected'
        stack_exposure = 2.^fstopDistance;
        
    otherwise
        error('ERROR: wrong mode for sampling the HDR image');
end

%allocate memory for the stack
n = length(stack_exposure);
stack = zeros(r, c, col, n);

%calculate exposures
for i=1:n
    img_e = (stack_exposure(i) * img);
    expo = ClampImg(ApplyCRF(img_e, lin_type, lin_fun), 0, 1);
    stack(:,:,:,i) = expo;
end

end

