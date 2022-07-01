function result = smoothImage(inputData,gBox,gSigma)
%smoothImage Smoothes bunch of 2D images. 
%   gBox = Gaussian box length of each side (in pixels)
%   gSigma = At how many pixels does gaussian wave reduce to 1/e of center?

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

% Gaussian box filter center
x0=ceil(gBox/2);
y0=ceil(gBox/2);

% Make Gaussian filter
G=zeros(gBox);
for x=1:gBox
    for y=1:gBox
        G(x,y)=exp((-(x-x0)^2-(y-y0)^2)/(2*gSigma^2));
    end
end
G=G/sum(G(:)); % normalize volume to 1

% Initialize
result=zeros(size(inputData));

% convolve data with filter

nanInd = isnan(inputData);
inputData(nanInd) = 0;

for c=1:size(inputData,3)
    for t=1:size(inputData,4)
        imageData = squeeze(inputData(:,:,c,t));
        imageResult=conv2(imageData,G,'same');
        result(:,:,c,t) = imageResult;
    end
end
result(nanInd) = nan;

end