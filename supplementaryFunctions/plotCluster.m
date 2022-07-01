function [axesList] = plotCluster(figH,contour,color,alpha)
%plotCluster Plot cluster locations and their p values
%   inputs:
%       figH
%       contour = mask data (logical)
%       color = color (rgb)
%       alpha = transparency (0 to 1)

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

% make new figure handle if it does not exist.
if isempty(figH)
    figH = figure;
end

if contains(class(figH),'Figure')
    isFig = true;
    dummyAxes = axes;
    axesPosition = dummyAxes.Position;
    set(dummyAxes,'Visible','off');
else
    isFig = false;
    dummyAxes = figH(1);
    axesPosition = dummyAxes.Position;
%     set(dummyAxes,'Visible','off');
end

% make new axes for cluster
hAxesContour = axes;
set(hAxesContour,'Position',axesPosition);

imageData = zeros([size(contour) 3]);
[row, col] = ind2D(find(contour),size(contour));
imageInd = repmat(row+((col-1)*size(contour,1)),3,1);
imageInd(numel(row)+1:2*numel(row)) = imageInd(numel(row)+1:2*numel(row)) + numel(contour);
imageInd(2*numel(row)+1:3*numel(row)) = imageInd(2*numel(row)+1:3*numel(row)) + 2*numel(contour);
imageData(imageInd(1:numel(row))) = color(1);
imageData(imageInd(numel(row)+1:2*numel(row))) = color(2);
imageData(imageInd(2*numel(row)+1:3*numel(row))) = color(3);

h = imshow(imageData);
set(h, 'AlphaData', alpha*contour);

axis(hAxesContour,'square');
set(hAxesContour,'Ydir','reverse');
set(hAxesContour,'Visible','off');

linkaxes([dummyAxes,hAxesContour]);
if isFig
    axesList = [dummyAxes hAxesContour];
else
    axesList = [figH hAxesContour];
end
end

