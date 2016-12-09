function [imgReference, imgDistorted, domain] = checkDomains(imgReference, imgDistorted)
%
%
%      [imgReference, imgDistorted, domain] = checkDomains(imgReference, imgDistorted)
%
%       This function checks if images belong to the same domain or not
%
%       Input:
%           -imgReference: input reference image
%           -imgDistorted: input distorted image
%
%       Output:
%           -imgReference: input reference image (cast to double)
%           -imgDistorted: input distorted image (cast to double)
%           -domain: image domain
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

if(isSameImage(imgReference, imgDistorted) == 0)
    error('The two images are different they can not be used or there are more than one channel.');
end

count = zeros(4, 1);
str{1} = 'uint8';
str{2} = 'uint16';
str{3} = 'single';
str{4} = 'double';

for i=1:length(str)
    
    if(isa(imgReference, str{i}))
        imgReference = double(imgReference);
        count(i) = count(i) + 1;
    end

    if(isa(imgDistorted, str{i}))
        imgDistorted = double(imgDistorted);
        count(i) = count(i) + 1;
    end
end

[value, index] = max(count);

if(value ~= 2)
    error('The two images have different domains.');
end

domain = str{index};

end