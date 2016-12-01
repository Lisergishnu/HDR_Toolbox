function imgOut = ChiuTMO(img, c_k, c_sigma, c_clamping, c_glare, c_glare_n, c_glare_width)
%
%       imgOut = ChiuTMO(img, c_k, c_sigma, c_clamping, c_glare, c_glare_n, c_glare_width)
%
%
%        Input:
%           -img: input HDR image
%           -c_k: scale correction
%           -c_sigma: local window size
%           -c_clamping: number of iterations for clamping and reducing
%                      halos. If it is negative, the clamping will not be
%                      calculate in the final image.
%           -c_glare: [0,1]. The default value is 0.8. If it is negative,
%                          the glare effect will not be calculated in the
%                          final image.
%           -c_glare_n: appearance (1,+Inf]. Default is 8.
%           -c_glare_width: size of the filter for calculating glare. Default is 121.
%
%        Output:
%           -imgOut: tone mapped image in linear space.
% 
%     Copyright (C) 2010-16 Francesco Banterle
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
%     The paper describing this technique is:
%     "Spatially Nonuniform Scaling Functions for High Contrast Images"
% 	  by Kenneth Chiu and M. Herf and Peter Shirley and S. Swamy and Changyaw Wang and Kurt Zimmerman
%     in Proceedings of Graphics Interface '93
%

%is it a three color channels image?
check13Color(img);

checkNegative(img);

%Luminance channel
L = lum(img);

r = size(img, 1);
c = size(img, 2);

%default parameters
if(~exist('c_k', 'var'))
    c_k = 8;
end

if(~exist('c_sigma', 'var'))
    c_sigma = round(16 * max([r, c]) / 1024) + 1;
end

if(~exist('c_clamping', 'var'))
    c_clamping = 500;
end

if(~exist('c_glare', 'var'))
    c_glare = 0.8;
end

if(~exist('c_glare_n', 'var'))
    c_glare_n = 8;    
end

if(~exist('c_glare_width', 'var'))
    c_glare_width = 121;
end

%cheking parameters
if(c_k <= 0)
    c_k = 8;
end

if(c_sigma <= 0)
    c_sigma = round(16 * max([r, c]) / 1024) + 1;
end
    
%calculate S
blurred = RemoveSpecials(1 ./ (c_k * GaussianFilter(L, c_sigma)));

%clamp S
if(c_clamping > 0)
    iL = RemoveSpecials(1./L);
    indx = find(blurred >= iL);
    blurred(indx) = iL(indx);

    %Smoothing S
    H2 = [0.080 0.113 0.080;...
          0.113 0.227 0.113;...
          0.080 0.113 0.080];

    for i=1:c_clamping
        blurred = imfilter(blurred, H2, 'replicate');
    end
end

%dynamic range reduction
Ld = L .* blurred;

if(c_glare > 0)
    %calculate a kernel with a Square Root shape for simulating glare
    window2 = round(c_glare_width / 2);
    [x, y] = meshgrid(-1:1 / window2:1,-1: 1 / window2:1);
    H3 = (1 - c_glare) * (abs(sqrt(x.^2 + y.^2) - 1)).^c_glare_n;    
    H3(window2 + 1, window2 + 1)=0;

    %circle of confusion of the kernel
    distance = sqrt(x.^2 + y.^2);
    H3(distance > 1) = 0;

    %normalize the kernel
    H3 = H3 / sum(H3(:));
    H3(window2 + 1, window2 + 1) = c_glare;
   
    %filter
    Ld = imfilter(Ld, H3, 'replicate');
end

%change luminance
imgOut = ChangeLuminance(img, L, Ld);

end