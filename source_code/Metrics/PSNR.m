function val = PSNR(img_ref, img_dist, max_value)
%
%
%      val = PSNR(img_ref, img_dist, max_value)
%
%
%       Input:
%           -img_ref: input reference image
%           -img_dist: input distorted image
%           -max_value: maximum value of images domain
%
%       Output:
%           -val: classic PSNR for images in [0,1]. Higher values means
%           better quality.
% 
%     Copyright (C) 2016  Francesco Banterle
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

[img_ref, img_dist, ~, mxt] = checkDomains(img_ref, img_dist);

mse = MSE(img_ref, img_dist);

if(~exist('max_value', 'var'))
    max_value = -1000;
end

if(max_value < 0.0)
    max_value = mxt;
end

if(mse > 0.0)
    val = 20 * log10(max_value / sqrt(mse));
else
    error('PSNR: mse values is zero or negative!'); 
end

end