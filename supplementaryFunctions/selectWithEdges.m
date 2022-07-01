function [selectedData, realInd, hasFalse] = selectWithEdges(data,ind,edgeLength)
%selectWithEdges Select a portion of the data with edges. Getting edges is
%important in removing edge effects for wavelet analysis. You need to know
%the length of data to add to edge. Run "makeGabor" function and see how
%long the wavelet is. edgeLength should be half of that rounded up.
%Inputs:
%   data = the actual data (last dim = time)
%   ind = two numbers. Where selection starts and ends
%   edgeLength = the number of data points in edges
%Outputs:
%   selectedData = the selected time series data
%   realInd = two numbers. Index of where the real data (not edges) start
%   and end
%   hasFalse = does the selectedData have any false data made by flipping
%   the real data to create edges?

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

origSize = size(data);
tNum = origSize(end);

data = reshape(data,[],tNum); % reshape to 2D

if edgeLength > size(data,2)
    error('The length of edge is too long.');
end

if size(data,2) == 1
    data = data';
end

realData = data(:,ind(1):ind(2));

% see how much data is missing on left end that needs to be created
leftFalseLen = edgeLength - (ind(1) - 1);
% see how much data is missing on left end that needs to be created
rightFalseLen = edgeLength - (tNum - ind(2));

% make boolean indicating whether false data was created.
if leftFalseLen > 0 || rightFalseLen > 0
    hasFalse = true;
else
    hasFalse = false;
end

% get left edge
if leftFalseLen <= 0
    leftEdge = data(:,ind(1)-edgeLength:ind(1)-1);
else
    leftEdge = data(:,1:ind(1)-1);
    falseLeftEdge = data(:,leftFalseLen:-1:1);
    leftEdge = [falseLeftEdge  leftEdge];
end

% get right edge
if rightFalseLen <= 0
    rightEdge = data(:,ind(2)+1:ind(2)+edgeLength);
else
    rightEdge = data(:,ind(2)+1:tNum);
    falseRightEdge = data(:,tNum:-1:tNum-rightFalseLen+1);
    rightEdge = [rightEdge falseRightEdge];
end

selectedData = [leftEdge realData rightEdge];
realInd = [size(leftEdge,2)+1 size(leftEdge,2) + size(realData,2)];

selectedData = reshape(selectedData,[origSize(1:end-1) size(selectedData,2)]);
end

