function coor = circleCoor(centerCoor,radius)
%circleCoor Generates coordiates that are within a circle
%   Input:
%       centerCoor = center coordinate (2 elements)
%       radius = 1 number
%   Output:
%       coor = nx2 output

% Copyright 2022 Washington University in St. Louis
% 
%    Licensed under the Apache License, Version 2.0 (the "License");
%    you may not use this file except in compliance with the License.
%    You may obtain a copy of the License at
% 
%        http://www.apache.org/licenses/LICENSE-2.0
% 
%    Unless required by applicable law or agreed to in writing, software
%    distributed under the License is distributed on an "AS IS" BASIS,
%    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%    See the License for the specific language governing permissions and
%    limitations under the License.

[candidateCoorX, candidateCoorY] = meshgrid(centerCoor(1)-radius:centerCoor(1)+radius,...
    centerCoor(2)-radius:centerCoor(2)+radius);

candidateCoorX = candidateCoorX(:);
candidateCoorY = candidateCoorY(:);

validPix = false(numel(candidateCoorX),1);
for pix = 1:numel(candidateCoorX)
    dist = sqrt((candidateCoorX(pix) - centerCoor(1))^2+(candidateCoorY(pix) - centerCoor(2))^2);
    if dist <= radius
        validPix(pix) = true;
    end
end

coor = [candidateCoorX(validPix) candidateCoorY(validPix)];

end

