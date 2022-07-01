function filtData = filterData(data,fMin,fMax,sR,varargin)
%filterData Band-pass filters data
%   data = nD matrix. last dim is time
%   fMin = minimum frequency
%   fMax = maximum frequency
%   sR = sampling rate

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

if numel(varargin)>0
    isbrain=varargin{1};
    isbrain=double(isbrain);
    data=data.*isbrain;
end


data(isnan(data))=0;
data(isinf(data))=0;

originalSize = size(data);

% vectorizes data into n x time
data = reshape(data,[],originalSize(end));

% initializes filtered data
filtData = zeros(size(data));

% filters for each pixel
for pixel = 1:size(data,1)
    if ~ (sum(data(pixel,:).^2)==0) || ~(sum(isnan(data(pixel,:)))==0) %ignore outside of brain (works if mask is nan or 0)
        
    ind = [1 size(data,2)];
    % select the data. Edges are considered to reduce edge effects.
    edgeLength = round(sR/fMin/2); % consider at least half the wavelength
    [selectedData, realInd, ~] = selectWithEdges(squeeze(data(pixel,:)),ind,edgeLength);
    
    % filter
    filtDataTemp = highpass(selectedData,fMin,sR);
    filtDataTemp = lowpass(filtDataTemp,fMax,sR);
    filtDataTemp = filtDataTemp(realInd(1):realInd(2));
    
    filtData(pixel,:) = filtDataTemp;
    
    end
    
end

% reshapes back into original shape
filtData = reshape(filtData,originalSize);
end

