function imgOut = ZhangLiTMO(img, a, sigma, k)
%
%        imgOut = ZhangLiTMO(img, a, sigma, k)
%
%
%        Input:
%           -img: input HDR image
%           -a: HC feedback parameter, default 0.2
%           -sigma: max coupling strength of HCs, default 1.0
%           -k: sensitivity of the inhibitory surround, default 0.5
%
%        Output:
%           -imgOut: tone mapped image
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
%     "A Retina Inspired Model for High Dynamic Range Image Rendering"
% 	  by Xian-Shi Zhang and Yong-Jie Li
%     in International Conference on Brain Inspired Cognitive Systems (BICS), 68-79, 2016.
%

%is it a gray/three color channels image?
check13Color(img);

checkNegative(img);

if(~exist('a', 'var'))
    a = 0.2;
end

if(~exist('sigma', 'var'))
    sigma = 1.0;
end

if(~exist('k', 'var'))
    k = 0.5;
end



imgSize = size(img);
sigmaCenter = 0.5;
sigmaSurround = 1.0;

% Allocate output image
imgOut = zeros(imgSize(1),imgSize(2));

% Calculate parameters for piecewise gaussian
m = mean(img(:));
s = std(img(:))/2;

% Operate per color channel
for c=1:3,
    % Generate piecewise kernels and images
    kernel1 = fspecial('gaussian',[16 16],sigma);
    kernel2 = fspecial('gaussian',[16 16],sigma * 3/5);
    kernel3 = fspecial('gaussian',[16 16],sigma * 2/5);
    kernel4 = fspecial('gaussian',[16 16],sigma / 5);
    BCfeedback1 = imfilter(img(:,:,c),kernel1,'same');
    BCfeedback2 = imfilter(img(:,:,c),kernel2,'same');
    BCfeedback3 = imfilter(img(:,:,c),kernel3,'same');
    BCfeedback4 = imfilter(img(:,:,c),kernel4,'same');
    
    % Compose feedback signal
    HCfeedback = zeros(imgSize(1), imgSize(2));
    for i=1:imgSize(1),
        for j=1:imgSize(2),
            cv = img(i,j,c);
            if cv < m - 3*s,
                HCfeedback(i,j) = BCfeedback4(i,j);
            elseif cv < m - 2*s,
                HCfeedback(i,j) = BCfeedback3(i,j);
            elseif cv < m - s,
                HCfeedback(i,j) = BCfeedback2(i,j);
            elseif cv < m+s,
                HCfeedback(i,j) = BCfeedback1(i,j);
            elseif cv < m + 2*s,
                HCfeedback(i,j) = BCfeedback2(i,j);
            elseif cv < m + 3*s,
                HCfeedback(i,j) = BCfeedback3(i,j);
            else
                HCfeedback(i,j) = BCfeedback4(i,j);
            end
        end
    end
    
    BCinput = img(:,:,c) ./ (a + HCfeedback);
    kernelCenter = fspecial('gaussian',[16 16],sigmaCenter);
    kernelSurround = fspecial('gaussian',[16 16],sigmaSurround);
    CC = imfilter(BCinput,kernelCenter,'same');
    SS = imfilter(BCinput,kernelSurround,'same');
    BCoutput = CC - k .* SS;
    imgOut(:,:,c) = BCoutput;
end

% Clamp negative and special values
imgOut(imgOut<0) = 0;
imgOut = RemoveSpecials(imgOut);
end