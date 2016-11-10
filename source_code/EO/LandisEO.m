function imgOut = LandisEO(img, Landis_alpha, Landis_threshold,  maxOutLuminance, gammaRemoval)
%
%       imgOut = LandisEO(img, Landis_alpha, Landis_threshold, maxOutLuminance, gammaRemoval)
%
%
%        Input:
%           -img:  input LDR image with values in [0,1]
%           -Landis_alpha: this value defines the 
%           -Landis_threshold: threshold for applying the iTMO
%           -maxOutLuminance: maximum output luminance
%           -gammaRemoval: the gamma value to be removed if known
%
%        Output:
%           -imgOut: an expanded image
%
%     Copyright (C) 2011-13  Francesco Banterle
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

check13Color(img);

if(~exist('maxOutLuminance', 'var'))
    maxOutLuminance = 3000.0;
end

if(maxOutLuminance < 0.0)
    maxOutLuminance = 3000.0;
end

if(~exist('gammaRemoval', 'var'))
    gammaRemoval = -1;
end

if(gammaRemoval > 0.0)
    img=img.^gammaRemoval;
end

%
%
%

if(~exist('Landis_alpha','var'))
    Landis_alpha = 2.0;   
end

if(~exist('Landis_threshold','var'))
    Landis_threshold = 0.5;
end

%Luminance channel
L = lum(img);

%Expanding from the mean value
if(Landis_threshold <= 0)
    Landis_threshold = mean(L(:));
end

%Finding pixels needed to be expanded
toExpand = find(L >= Landis_threshold);

%Exapnsion using a power function
maxValL = max(L(:)); %generalization in the case of unnormalized data
weights = ((L(toExpand) - Landis_threshold) / (maxValL - Landis_threshold)).^Landis_alpha;

Lexp = L;
Lexp(toExpand) = L(toExpand) .* (1 - weights) + maxOutLuminance * L(toExpand) .* weights;

%Removing the old luminance
imgOut = ChangeLuminance(img, L, Lexp);

end