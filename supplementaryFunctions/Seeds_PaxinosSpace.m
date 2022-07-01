function [Seeds, L]=Seeds_PaxinosSpace

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

%These are the atlas coordinates of our seed locations

%% Seeds (x,y), R=Right, L=Left

Seeds.R.Fr=[1.3 3.3];   %Frontal
Seeds.R.Cing=[0.3 1.8]; %Cingulate
Seeds.R.M=[1.5 2];      %Motor
Seeds.R.SS=[3.6 -0.15]; %Somatosenory
Seeds.R.Ret=[0.5 -2.1]; %Retrosplenial
Seeds.R.P=[1.75 -1.85]; %Parietal
Seeds.R.V=[2.4 -4];     %Visual
Seeds.R.Aud=[4.2 -2.7]; %Auditory


   

Seeds.L.Fr=[-1.3 3.3];   %Frontal
Seeds.L.Cing=[-0.3 1.8]; %Cingulate
Seeds.L.M=[-1.5 2];      %Motor
Seeds.L.SS=[-3.6 -0.15]; %Somatosenory
Seeds.L.Ret=[-0.5 -2.1]; %Retrosplenial
Seeds.L.P=[-1.75 -1.85]; %Parietal
Seeds.L.V=[-2.4 -4];     %Visual
Seeds.L.Aud=[-4.2 -2.7]; %Auditory



L.bregma=[0 0];
L.tent=[0 -3.9];
L.of=[0 3.525];

end

