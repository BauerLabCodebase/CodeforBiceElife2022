function [axesList] = plotCluster(figH,contour,color,alpha)
%plotCluster Plot cluster locations and their p values
%   inputs:
%       figH
%       contour = mask data (logical)
%       color = color (rgb)
%       alpha = transparency (0 to 1)

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

