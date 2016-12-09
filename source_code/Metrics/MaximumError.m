function maxErr = MaximumError(imgReference, imgDistorted)
%
%
%      maxErr = MaximumError(imgReference, imgDistorted)
%
%       the maximum error between two images
%
%       Input:
%           -imgReference: input reference image
%           -imgDistorted: input distorted image
%
%       Output:
%           -val: the absolute maximum error between imgReference and imgDistorted
% 
%     Copyright (C) 2014-2015  Francesco Banterle
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

[imgReference, imgDistorted, ~] = checkDomains(imgReference, imgDistorted);

delta = abs(imgReference - imgDistorted);

maxErr = max(delta(:));

end