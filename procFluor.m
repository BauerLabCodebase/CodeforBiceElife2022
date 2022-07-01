function fluorData = procFluor(rawData,baseline)
%procFluor Preprocessing for fluorescence data
%   detrendBool = if true, detrends using info's highpass filter frequency
fluorData = double(rawData);
clear rawData
 if ~exist('baseline','var')
    baseline = nanmean(fluorData,length(size(fluorData)));
 else
     baseline = double(baseline);
 end

fluorData = fluorData./repmat(baseline,[1 1 1 size(fluorData,4)]); % make the data ratiometric


fluorData = fluorData - 1; % make the data change from baseline (center at zero)
%fluorData = mouse.process.smoothImage(fluorData,5,1.2); % spatially smooth data
fluorData = single(fluorData);
end

