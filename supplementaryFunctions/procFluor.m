function fluorData = procFluor(rawData,baseline)
%procFluor Preprocessing for fluorescence data

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

