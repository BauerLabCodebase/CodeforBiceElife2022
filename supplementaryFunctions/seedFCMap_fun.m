function fcData = seedFCMap(data,roi)
% seedFC outputs map of FC to seed
%   inputs:
%       data = 3D matrix. (spatial x spatial x time)
%       roi = Boolean 2D matrix

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

%% fc

roi = roi(:);

ySize = size(data,1);
xSize = size(data,2);

data = reshape(data,[],size(data,3));
roiData = nanmean(data(roi,:),1)';
%normr(roiData*data') convert corr way to easy-bauer way

fcData = corr(roiData,data');
fcData = reshape(fcData,ySize,xSize);

end


