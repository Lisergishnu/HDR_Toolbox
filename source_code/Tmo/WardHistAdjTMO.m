function imgOut = WardHistAdjTMO(img, nBin, LdMin, LdMax, bPlotHistogram)
%
%        imgOut = WardHistAdjTMO(img, nBin, LdMin, LdMax, bPlotHistogram)
%
%
%        Input:
%           -img: input HDR image
%           -nBin: number of bins for calculating the histogram (1,+Inf)
%           -LdMin: minimum luminance value of the display
%           -LdMax: maximum luminance value of the display
%           -bPlotHistogram:
%
%        Output:
%           -imgOut: tone mapped image
% 
%     Copyright (C) 2010-16  Francesco Banterle
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
%     "A Visibility Matching Tone Reproduction Operator for High Dynamic Range Scenes"
% 	  by Gregory Ward Larson, Holly Rushmeier, Christine Piatko
%     in IEEE Transactions on Visualization and Computer Graphics 1997
%

%is it a gray/three color channels image?
check13Color(img);

checkNegative(img);

if(~exist('nBin', 'var'))
    nBin = 256;
end

if(~exist('LdMin', 'var'))
    LdMin = 1; %cd/m^2
end

if(LdMin <= 0.0)
    LdMin = 1;
end

if(~exist('LdMax', 'var'))
    LdMax = 100; %cd/m^2
end

if(LdMax <= 0.0)
    LdMax = 100;
end

if(LdMax < LdMin)
    tmp = LdMin;
    LdMin = LdMax;
    LdMax = tmp;
end

if(~exist('bPlotHistogram', 'var'))
    bPlotHistogram = 0;
end

if(nBin <= 1)
    nBin = 256;
end

%compute luminance channel
L = lum(img);

L2 = WardDownsampling(L);
LMax = max(L2(:));
LMin = min(L2(:));
if(LMin <= 0.0)
     LMin = min(L2(L2 > 0.0));
end

%Log space
Llog  = log(L2);
LlMax = log(LMax);
LlMin = log(LMin);
LldMax = log(LdMax);
LldMin = log(LdMin);

%compute function p
p = zeros(nBin, 1);
delta = (LlMax - LlMin) / nBin;

for i=1:nBin
    indx = find(Llog > (delta * (i - 1) + LlMin) & Llog <= (delta * i + LlMin));
    p(i) = numel(indx);
end

%apply histogram ceiling
if(bPlotHistogram)
    bar(p);
    hold on;
end

p = histogram_ceiling(p, delta / (LldMax - LldMin));

if(bPlotHistogram)
    bar(p);
    hold off;
end

%compute P(x) 
Pcum = cumsum(p);
Pcum = Pcum / max(Pcum);

%calculate tone mapped luminance
L(L > LMax) = LMax;
x = (LlMin:((LlMax - LlMin) / (nBin - 1)):LlMax)';
PcumL = interp1(x , Pcum , real(log(L)), 'linear');
Ld  = exp(LldMin + (LldMax - LldMin) * PcumL);
Ld  = (Ld - LdMin) / (LdMax - LdMin); %normalize in [0,1]

%change luminance
imgOut = ChangeLuminance(img, L, Ld);
end
