function result = temporalDetrend(inputData,isbrain)
%temporalDetrend Temporally detrends by fiting to a polynomial.
% input:
%   inputData = nD matrix. Last dim is time.
%   usePoly (optional) = Determining whether to use polyfit option.
%   Default is 0.
%       0 = using highpass filter. The frequency threshold is the frequency
%       resulting in 2 cycles within data length, or 0.004 Hz, whichever is
%       higher.
%       1 = polyfit but with division
%       2 = polyfit but with subtraction

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

% if numel(varargin) > 0
%     usePoly = varargin{1};
% else
%     usePoly = 2;
% end

isbrain_ind=find(isbrain); %indices that are inside the mask
rawSize = size(inputData);
tSize = size(inputData,numel(rawSize));

%temporal detrend
rawReshaped = reshape(inputData,[],tSize);

% if usePoly == 1 %division
%     timeTrend = zeros(size(rawReshaped));
% 
%     for ii = 1:size(rawReshaped(isbrain_ind,:),1)
%         timeTrend(isbrain_ind(ii),:) = polyval(polyfit(1:tSize, rawReshaped(isbrain_ind(ii),:), 5), 1:tSize);
%     end
%     rawFrameOne = rawReshaped(:,1);
%     rawFrameOne = reshape(rawFrameOne,rawSize(1:end-1)); %reshape into image
%     timeTrend = reshape(timeTrend,rawSize);
%     detrendedData = inputData./timeTrend;
%     detrendedData(isinf(detrendedData))=0;
%     result = bsxfun(@times,detrendedData, rawFrameOne); %multiplication 
% 
% elseif usePoly == 2
    warning('Off');

    for ii = 1:size(rawReshaped(isbrain_ind,:),1)
        timeTrend = polyval(polyfit(1:tSize, rawReshaped(isbrain_ind(ii),:), 5), 1:tSize);
        rawReshaped(isbrain_ind(ii),:) = rawReshaped(isbrain_ind(ii),:) - timeTrend + mean(rawReshaped(isbrain_ind(ii),:));
    end
    result = reshape(rawReshaped,rawSize);
    warning('On');

% end