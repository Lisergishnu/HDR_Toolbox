function imgOut = AkyuzEO(img, maxOutLuminance, gammaAkyuz, gammaRemoval)
%
%       imgOut = AkyuzEO(img, maxOutLuminance, gammaAkyuz, gammaRemoval)
%
%
%        Input:
%           -img: input LDR image with values in [0,1]
%           -maxOutLuminance: the maximum output luminance value defines the 
%           -gammaAkyuz: this value defines the appearance
%           -gammaRemoval: the gamma value to be removed if known
%
%        Output:
%           -imgOut: an expanded image
%
%     Copyright (C) 2011-2016  Francesco Banterle
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

if(~exist('gammaAkyuz', 'var'))
    gammaAkyuz = 1.0;
end

L = lum(img);
L_max = max(L(:));
L_min = min(L(:));
Lexp = maxOutLuminance * (((L - L_min) / (L_max - L_min)).^gammaAkyuz);

%Removing the old luminance
imgOut = ChangeLuminance(img, L, Lexp);

end
