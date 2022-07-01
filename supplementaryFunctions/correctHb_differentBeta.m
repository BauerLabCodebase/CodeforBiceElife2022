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
