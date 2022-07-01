function [row,col] = ind2D(index,matSize)
%ind2D Converts index of 2D matrix to 2D coordinates
%   Inputs:
%       index = index of data in vector
%       matSize = 2 values referring to size of 2 dimensions
%   Outputs:
%       row = first dim ind
%       col = second dim ind

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

col = ceil(index/matSize(1));
row = (mod(index-1,matSize(1))+1);
end

