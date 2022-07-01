function [displacement, tx, ty,offset] = checkMovement(data)
%checkMovement Checks movement of data spatially
% Shuffles pixels in the same manner for each time frame, and finds the
% correlation of the shuffled data to baseline shuffled data (first frame).
% Inputs:
%   data = light intensity data. Make sure data from only one light source
%   is included. Otherwise, data from different light sources may be
%   considered movement. 3 dimensions. Last dimension is time
% Outputs:
%   displacement = displacement magnitude in pixels
%   tx = translation in first dim
%   ty = translation in second dim
% from OIS repo

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

dataSize = size(data);

data(isnan(data)) = 0;

tNum = dataSize(end);

Im1=single(squeeze(data(:,:,1)));
F1 = fft2(Im1); % reference image

InstMvMt=zeros(tNum,1);
LTMvMt=zeros(tNum,1);
shift=zeros(2,tNum,1);

for t=1:tNum-1
    LTMvMt(t)=sum(sum(abs(squeeze(data(:,:,t+1))-Im1)));
    InstMvMt(t)=sum(sum(abs(squeeze(data(:,:,t+1))-squeeze(data(:,:,t)))));
end

for t=1:tNum
    Im2=single(squeeze(data(:,:,t)));
    F2 = fft2(Im2); % subsequent image to translate
    
    pdm = exp(1i.*(angle(F1)-angle(F2))); % Create phase difference matrix
    pcf = real(ifft2(pdm)); % Solve for phase correlation function
    pcf2(1:size(Im1,1)/2,1:size(Im1,1)/2)=pcf(size(Im1,1)/2+1:size(Im1,1),size(Im1,1)/2+1:size(Im1,1)); % 4
    pcf2(size(Im1,1)/2+1:size(Im1,1),size(Im1,1)/2+1:size(Im1,1))=pcf(1:size(Im1,1)/2,1:size(Im1,1)/2); % 1
    pcf2(1:size(Im1,1)/2,size(Im1,1)/2+1:size(Im1,1))=pcf(size(Im1,1)/2+1:size(Im1,1),1:size(Im1,1)/2); % 3
    pcf2(size(Im1,1)/2+1:size(Im1,1),1:size(Im1,1)/2)=pcf(1:size(Im1,1)/2,size(Im1,1)/2+1:size(Im1,1)); % 2
    
    [~, imax] = max(pcf2(:));
    [ypeak, xpeak] = ind2sub(size(Im1,1),imax(1));
    offset = [ypeak-(size(Im1,1)/2+1) xpeak-(size(Im1,2)/2+1)];
    
    shift(1,t)=offset(1);
    shift(2,t)=offset(2);
    
end

tx = shift(1,:);
ty = shift(2,:);
displacement = sqrt(tx.^2+ty.^2);
end

