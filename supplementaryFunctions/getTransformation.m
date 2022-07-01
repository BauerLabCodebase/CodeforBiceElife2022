function [mytform,fixed_cam1,registered_cam2] = getTransformation(firstFrame_cam1,firstFrame_cam2)

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

fixed_cam1 = firstFrame_cam1./max(max(firstFrame_cam1));
unregistered_cam2 = firstFrame_cam2./max(max(firstFrame_cam2));
f = msgbox(['click four pairs of points',newline,'export in movingPoints and fixedPoints',newline,'close after finish selection']);
pause(0.5)
[movingPoints,fixedPoints] = cpselect(unregistered_cam2,fixed_cam1,'Wait',true);
mytform = fitgeotrans(movingPoints, fixedPoints, 'projective');

registered_cam2 = imwarp(unregistered_cam2, mytform,'OutputView',imref2d(size(unregistered_cam2)));
C  = imfuse(registered_cam2,fixed_cam1,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
figure;
imagesc(C);
axis image off
title('projective')