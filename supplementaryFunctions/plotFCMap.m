function f1 = plotFCMap(f1,axPos,fcMap,mask)
%plotFCMap plots the functional connectivity map
%
% Inputs:
%   f1 = figure handle (creates new fig if empty)
%   axPos = where the seed fc plot should be stationed. If empty, default
%   is used, which is [0 0 1 1].
%   fcMap = yCoor x xCoor x seed
%   mask

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

if isempty(f1)
    f1 = figure('Position',[100 100 400 300]);
end
if isempty(axPos)
    axPos = [0 0 1 1];
end

rowTop = 0.94; rowTop = rowTop*axPos(4) + axPos(2);
rowBottom = 0.03; rowBottom = rowBottom*axPos(4) + axPos(2);
colLeft = 0.1; colLeft = colLeft*axPos(3) + axPos(1);
colRight = 0.9; colRight = colRight*axPos(3) + axPos(1);

s1 = axes('Position',[colLeft rowBottom colRight-colLeft rowTop-rowBottom]);
imagesc(fcMap,'AlphaData',mask,[-1 1]);
colormap('jet'); cb=colorbar;cb.Label.String='Correlation Coefficient (r)';
yticks(s1,[]); xticks(s1,[]);
axis(s1,'square');
set(s1,'Visible','off');

end