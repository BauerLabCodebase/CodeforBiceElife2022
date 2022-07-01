function [axesList, p] = plotBrain(figH,brainVal,brainMask,varargin)
%plotBrain Outputs brain mask image with nodes drawn on top of it
%   figH = figure handle. If empty a new figure will be created.
%   brainVal = (m x m) matrix showing image value.
%   brainMask = (m x m) matrix showing the mask of the brain (logical)
%   cLim (optional) = (2x1) vector stating the values' color lim (default =
%   [0 1])
%   cMap (optional) = colormap. (default = gray)
%   addColorbar (optional) = whether to add colorbar (default = false)
%   colorbarOffset (optional) = how much to push colorbar to the right
%   (default = 0.03);
%   Output:
%       [axesList, p]
%       axesList = list of figure axes
%       p = handle for image (imagesc)

if numel(varargin) < 1
    cLim = [0 1];
else
    cLim = varargin{1};
end

if numel(varargin) < 2
    cMap = gray(100);
else
    cMap = varargin{2};
end

if numel(varargin) < 3
    addColorbar = false;
else
    addColorbar = varargin{3};
end

if numel(varargin) < 4
    colorbarOffset = 0.03;
else
    colorbarOffset = varargin{4};
end

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

% make new axes for imagesc of mask
hAxesMask = axes;
set(hAxesMask,'Position',axesPosition);

% plot mask
if numel(size(brainVal)) == 3
    p = imshow(brainVal);
    set(p, 'AlphaData', brainMask);
else
    p = imagesc(brainVal,'AlphaData',brainMask,cLim);
end
xlim([1 size(brainMask,1)]);
ylim([1 size(brainMask,2)]);
set(hAxesMask,'Visible','off');
colormap(hAxesMask,cMap);
axis(hAxesMask,'square');

if addColorbar
    % make another axes just for colorbar
    hAxesBar = axes;
    set(hAxesBar,'Position',axesPosition);
    set(hAxesBar,'Visible','off');
    axis(hAxesBar,'square');
    barPos = get(hAxesBar,'position');
    
    % brain mask lim
    maskLimY = sum(brainMask,2) > 0;
    maskLimY = [size(brainMask,1)-find(maskLimY,1,'last')+1 size(brainMask,1)-find(maskLimY,1,'first')];
    maskLimY = (maskLimY-1)./(size(brainMask,1)-1);
    maskLimY(1) = max([maskLimY(1) 0.2]);
    maskLimY(2) = min([maskLimY(2) 0.8]);
    
    barPos(1) = barPos(1) + colorbarOffset;
    barPos(3) = barPos(3) + colorbarOffset;
    barPos(2) = barPos(2)+barPos(4)*maskLimY(1);
    barPos(4) = barPos(4)*diff(maskLimY);
    cbh = colorbar;
    colormap(hAxesBar,cMap);
    caxis(hAxesBar,cLim);
    set(hAxesBar,'Position',barPos);
    set(cbh,'YTick',linspace(cLim(1),cLim(2),5))
    linkaxes([dummyAxes,hAxesMask, hAxesBar]);
    if isFig
        axesList = [dummyAxes hAxesMask hAxesBar];
    else
        axesList = [figH hAxesMask hAxesBar];
    end
else
    %link the two overlaying axes so they match at all times to remain accurate
    linkaxes([dummyAxes,hAxesMask]);
    if isFig
        axesList = [dummyAxes hAxesMask];
    else
        axesList = [figH hAxesMask];
    end
end

end

