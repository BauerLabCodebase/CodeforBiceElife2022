function [fh, seedFC, seedFCMap,seedCenter,seedRadius,bilatFCMap] = qcFC(data,mask,contrastName,runInfo,fRange,Cont2Plot)
%qcRawFig Generates figure with quality control for raw data
% Inputs:
%   data = cell array of data
%   mask = cell array of brain mask (Boolean). Note that this is for
%   displaying. Calculations of non-isbrain are still calculated
%   samplingRate = array of sampling rate
%   contrastName = cell array of name of each contrast ex: 'HbT'
%   runInfo
%   fRange (optional) = frequency range (default = 0.009 ~ 0.08 Hz)
% Outputs:
%   fcFig = figure handle for fc figure
%   seedFC = seeds by seeds matrix
%   seedFCMap = y by x by seeds matrix showing fc maps for each seed
%   seedCenter = n by 2 matrix showing coordinates of seed centers
%   seedRadius

fStr = [num2str(fRange(1)) '-' num2str(fRange(2))];

refseeds=GetReferenceSeeds;
seedCenter = flip(refseeds,2);

seedNames = {'Fr-L'  'Cing-L' 'M-L' 'SS-L' 'RS-L' 'P-L' 'V-L' 'Aud-L'...
    'Fr-R' 'Cing-R' 'M-R' 'SS-R' 'RS-R' 'P-R' 'V-R' 'Aud-R'};
seedNum = size(seedCenter,1);
seedFC = nan(seedNum,seedNum,size(data,4));
seedFCMap = nan(size(data,1), size(data,2),seedNum,size(data,4) );
bilatFCMap =nan(size(data,1), size(data,2),size(data,4) );
% run for each contrast
ind=0;

for contrast = 1:size(data,4)
    cData = squeeze(data(:,:,:,contrast));
    
    %Get seeds
    numPixY = size(cData,1); % number of pixels in y axis
    numPixX = size(cData,2);
    sizeY = runInfo.window(2)-runInfo.window(1); % size in mm in y axis
    seedRadius = 0.25; % in mm
    seedRadius = round(seedRadius/sizeY*numPixY);
    
    %Get seed maps
    seedMap = false(numPixY,numPixX,seedNum);
    for seedInd = 1:seedNum
        seedCoor = circleCoor(seedCenter(seedInd,:),seedRadius);
        seedCoor = matCoor2Ind(seedCoor,[numPixY numPixX]);
        seedBool = false(numPixY,numPixX); seedBool(seedCoor) = true;
        seedMap(:,:,seedInd) = seedBool;
    end
    
    % get seed fc
    for seedInd = 1:seedNum
        %this takes a few minutes
        seedFCMap(:,:,seedInd,contrast) = seedFCMap_fun(cData,seedMap(:,:,seedInd)); 
    end
    %fc matrix
    seedFC(:,:,contrast) = seedFC_fun(cData,seedMap);
    
    % get bilateral fc
    bilatFCMap(:,:,contrast) = bilateralFC_fun(cData);

    
%plotting    
    if sum(contains(Cont2Plot,contrastName{contrast}))>0 
        ind=ind+1;

    fh(ind) = figure('Position',[100 100 1200 500]);
    %seedMap and Matrix
    seedFCPos = [0.02 0.05 0.6 0.85];
    fh(ind) = plotSeedFC(fh(ind),seedFCPos,...
        seedFCMap(:,:,:,contrast),seedFC(:,:,contrast),...
        seedCenter, seedMap, seedRadius,seedNames,mask);
    %Bilat
    bilatFCPos = [0.62 0.05 0.36 0.85];
    mask(:,63:66) = 0;%%mask out midline
    MaskMirrored = mask & fliplr(mask);
    fh(ind) = plotFCMap(fh(ind),bilatFCPos,...
        bilatFCMap(:,:,contrast),MaskMirrored);
    
    % plot title
    titleAxesHandle=axes('position',[0 0 1 0.95]);
    currentMouse = [runInfo.recDate, '-', runInfo.mouseName, '-', runInfo.session, char(string(runInfo.run))];
    t = title(titleAxesHandle,[currentMouse ', ' contrastName{contrast} ' FC, ' fStr 'Hz']);
    set(titleAxesHandle,'visible','off');
    set(t,'visible','on');
    end
end
end
