function f1 = plotSeedFC(f1,axPos,seedFCMap,seedFC,seedLoc,seedMap, seedRadius,seedNames,mask)
%plotSeedFC plots the functional connectivity map relative to each seed.
%Outputs a figure handle.
%
% Inputs:
%   f1 = figure handle (creates new fig if empty)
%   axPos = where the seed fc plot should be stationed. If empty, default
%   is used, which is [0 0 1 1].
%   seedFCMap = yCoor x xCoor x seed
%   seedFC = seed x seed
%   seedLoc = seed x 2 (y, x coordinate of seeds)
%   seedRadius = integer
%   seedNames = cell array of char arrays
%   mask

ySize = size(seedFCMap,1);
xSize = size(seedFCMap,2);
seedNum = size(seedLoc,1);
rowNum = 4;
colNum = ceil(seedNum/rowNum);

if isempty(f1)
    f1 = figure('Position',[100 100 colNum*260 rowNum*100]);
end
if isempty(axPos)
    axPos = [0 0 1 1];
end

seedFCColMax = 0.5; % maximum axis size on x for seed fc maps
rowTop = 0.94; rowTop = rowTop*axPos(4) + axPos(2);
rowBottom = 0.03; rowBottom = rowBottom*axPos(4) + axPos(2);
colLeft = 0; colLeft = colLeft*axPos(3) + axPos(1);
colRight = 1; colRight = colRight*axPos(3) + axPos(1);
rowWidth = 1/rowNum*(rowTop-rowBottom);
colWidth = 1/(colNum+0.3)*(colRight-colLeft)*seedFCColMax;

for seedInd = 1:seedNum
    
    fc = seedFCMap(:,:,seedInd);
    
    if seedInd == seedNum
        addCBar = true;
    else
        addCBar = false;
    end
    
    seedRow = ceil(seedInd/colNum);
    seedCol = mod((seedInd-1),colNum)+1;
    
    subLeft = colLeft+(seedCol-1)*(colWidth);
    subBottom = rowBottom+(rowNum-seedRow)*(rowWidth);
    
    s1 = axes('Position',[subLeft subBottom colWidth*0.9 rowWidth*0.8]);
    set(s1,'Visible','off');
    s1 = plotBrain(s1,fc,mask,[-1 1],jet(100),addCBar,0.03*(colRight-colLeft));
    s1 = plotCluster(s1,seedMap(:,:,seedInd),[0 0 0],1);
    title(seedNames{seedInd});
    yticks(s1,[]); xticks(s1,[]);
end

seedFCLeft = colLeft + (colRight-colLeft)*(seedFCColMax+0.05);
seedFCXWidth = (colRight-colLeft)*(1-(seedFCColMax+0.05));
seedFCBottom = rowBottom+0.1*(rowTop-rowBottom);
seedFCYWidth = 0.85*(rowTop-rowBottom);

s1 = axes('Position',[seedFCLeft seedFCBottom seedFCXWidth seedFCYWidth]);
imagesc(seedFC,[-1 1]); colormap('jet'); cb=colorbar; axis(gca,'square');
cb.Label.String='Correlation Coefficient (r)';
yrule = s1.YAxis;
yrule.FontSize = round(f1.Position(4)*axPos(4)*0.3/seedNum);
xrule = s1.XAxis;
xrule.FontSize = round(f1.Position(4)*axPos(4)*0.3/seedNum);
xticks(1:seedNum); xticklabels(seedNames); xtickangle(90);
yticks(1:seedNum); yticklabels(seedNames);
end