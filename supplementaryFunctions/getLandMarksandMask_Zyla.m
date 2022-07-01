function [isbrain,xform_isbrain,I,seedcenter,WLcrop,xform_WLcrop,xform_WL] = getLandMarksandMask_Zyla(WL)
% loads mask file in and outputs white light image while getting landmarks
% for affine transform

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

[I, seedcenter]=MakeSeedsMouseSpace(WL);

disp('Create mask')
mask=roipoly(WL);

if ~any(any(mask))
    load('D:\OIS_Process\Paxinos\AtlasandIsbrain.mat', 'parcelisbrainPS');
    isbrain=InvAffine(I, parcelisbrainPS, 'New');
    isbrain=single(uint8(isbrain));
    [xform_isbrain]=affineTransform(isbrain,I);
    xform_isbrain=single(uint8(xform_isbrain));
    
    [xform_WL]=affineTransform(WL,I);
    
    for j=1:3
        xform_WLcrop(:,:,j)=xform_WL(:,:,j).*parcelisbrainPS; %make affine transform WL image
    end
    
    WLcrop=WL;
    for j=1:3
        WLcrop(:,:,j)=WLcrop(:,:,j).*isbrain; %make WLcrop image
    end
    
else
    
    isbrain=single(uint8(mask));
    [xform_isbrain]=affineTransform(isbrain,I);
    xform_isbrain=single(uint8(xform_isbrain));
    
    [xform_WL]=affineTransform(WL,I);
    
    for j=1:3
        xform_WLcrop(:,:,j)=xform_WL(:,:,j).*xform_isbrain; %make affine transform WL image
    end
    
    WLcrop=WL;
    for j=1:3
        WLcrop(:,:,j)=WLcrop(:,:,j).*isbrain; %make WLcrop image
    end
end
end
