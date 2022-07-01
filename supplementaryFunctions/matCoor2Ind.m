function ind = matCoor2Ind(coor,matSize)
%matCoor2Ind Summary of this function goes here
%   Inputs:
%       coor = m x n where m is number of points and n is number of
%       coordinates per point
%       matSize = matrix size

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

subMatSize = nan(numel(matSize),1);
subMatSize(1) = 1;
for dim = 2:numel(subMatSize)
    subMatSize(dim) = prod(matSize(1:dim-1));
end

ind = coor(:,1);
for dim = 2:numel(subMatSize)
    ind = ind + (coor(:,dim)-1)*subMatSize(dim);
end

end

