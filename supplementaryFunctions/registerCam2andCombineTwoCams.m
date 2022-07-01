function raw  = registerCam2andCombineTwoCams(rawdata_cam1,rawdata_cam2,mytform,cam1Chan,cam2Chan)

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

registered_cam2 = zeros(size(rawdata_cam2));

channels_cam2 = size(rawdata_cam2,3);
for ii = 1: channels_cam2
    for jj = 1:size(rawdata_cam2,4)
        registered_cam2(:,:,ii,jj) = imwarp(rawdata_cam2(:,:,ii,jj), mytform,'OutputView',imref2d(size(rawdata_cam2)));
    end
end

channels = size(rawdata_cam1,3)+size(rawdata_cam2,3);
raw = zeros(size(rawdata_cam1,1),size(rawdata_cam1,2),channels,size(rawdata_cam1,4));
raw(:,:,cam1Chan,:) = rawdata_cam1;
raw(:,:,cam2Chan,:) = registered_cam2;
