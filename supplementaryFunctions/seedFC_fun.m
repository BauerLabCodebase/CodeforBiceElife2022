function fcData = seedFC_fun(data,roi)
% seedFC outputs map of FC to seed
%   inputs:
%       data = 3D matrix. (spatial x spatial x time)
%       roi = 3D Boolean matrix. (spatial x spatial x seeds). Each image,
%       for pixels that are true, are considered as part of that seed.

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
seedNum = size(roi,3);
fcData = nan(seedNum);

data = reshape(data,[],size(data,3));

seedData = nan(size(data,2),seedNum);
for seed = 1:seedNum
    seedData(:,seed) = nanmean(data(squeeze(roi(:,:,seed)),:),1);
end

for seed1 = 1:seedNum
    for seed2 = 1:seedNum
        fcData(seed1,seed2) = corr(seedData(:,seed1),seedData(:,seed2));
    end
end

end