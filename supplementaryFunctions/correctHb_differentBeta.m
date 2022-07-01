function fluorCorr = correctHb_differentBeta(fluor,hb,hbOExtCoeff,hbRExtCoeff,bluePath,greenPath,alpha,beta)
%UNTITLED Summary of this function goes here
%   Inputs:
%       fluor = fluorescence data (spatial x spatial x time)
%           fluorescence should be change in ratio (not abs value) (so
%           usually this is expected to center around zero)
%       hb = hemoglobin data (spatial x spatial x 2 x time)
%           3rd dimension is species (HbO and HbR) (M)
%       hbOExtCoeff = hbO extinction coefficient (1 x 2)
%       hbRExtCoeff = hbR extinction coefficient (1 x 2)
%       bluePath = blue light path (cm)
%       greenPath = green light path (cm)

fluor = fluor + 1;

fluorCorr = nan(size(fluor));
for y = 1:size(hb,1)
    for x = 1:size(hb,2)
        hbOData = squeeze(hb(y,x,1,:));
        hbRData = squeeze(hb(y,x,2,:));
        
        fluorData = squeeze(fluor(y,x,:)); % change (logmean or percentage change)
        
        [fluorDataHbRemoved] = rmvHbAbs_differentBeta(fluorData,hbOData,hbRData,...
            hbOExtCoeff,hbRExtCoeff,bluePath,greenPath,alpha,beta);
        
        fluorCorr(y,x,:) = fluorDataHbRemoved;
    end
end

fluorCorr = fluorCorr - 1;

end
