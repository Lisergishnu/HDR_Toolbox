function val = PSNR(imgReference, imgDistorted)
%
%
%      val = PSNR(imgReference, imgDistorted)
%
%
%       Input:
%           -imgReference: input reference image
%           -imgDistorted: input distorted image
%
%       Output:
%           -val: classic PSNR for images in [0,1]. Higher values means
%           better quality.
% 
%     Copyright (C) 2006  Francesco Banterle
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

[imgReference, imgDistorted, domain] = checkDomains(imgReference, imgDistorted);

mse = MSE(imgReference, imgDistorted);

switch domain
    case 'uint8'
        max_value = 2^8 - 1;
        
    case 'uint16'
        max_value = 2^16 - 1;
        
    case 'single'
        max_value = max(imgReference(:));
        
    case 'double'
        max_value = max(imgReference(:));      
end
        
if(mse > 0.0)
    val = 20 * log10(max_value / sqrt(mse));
else
    error('PSNR: mse values is zero or negative!'); 
end

end