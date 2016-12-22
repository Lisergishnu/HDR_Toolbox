function rmse = logRMSE(img_ref, img_dist)
%
%
%      val = logRMSE(img_ref, img_dist)
%
%
%       Input:
%           -img_ref: input source image
%           -img_dist: input target image
%
%       Output:
%           -rmse: RMSE in Log2 Space for three channels images. Lower
%           values means better quality.
% 
%     Copyright (C) 2006-2015  Francesco Banterle
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

if(isSameImage(img_ref, img_dist) == 0)
    error('The two images are different they can not be used.');
end

acc = zeros(size(img_ref, 1), size(img_ref, 2));

col = size(img, 3);
for i=1:col
    tmp = log10(img_ref + 1e-6) - log10(img_dist + 1e-6);
    acc = acc + tmp.^2;
end

mse = mean(acc(:));

rmse = sqrt(mse);

end