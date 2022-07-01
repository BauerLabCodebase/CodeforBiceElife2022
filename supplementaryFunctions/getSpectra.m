function [spectra, wavelength]=getSpectra(fileNames)
% getSourceSpectra Obtains spectral information of light sources from their
% text files
%   Inputs:
%       fileNames = cell array of char vectors
%   Outputs:
%       spectra = cell array containing spectrum, which is variable containing
%       LED intensity at certain wavelength;
%       wavelength = cell array containing wavelength

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

fileNum = numel(fileNames);

for fileInd = 1:fileNum
    if iscell(fileNames)
        fileName = fileNames{fileInd};
    else
        fileName = char(fileNames(fileInd));
    end
    
    fid=fopen(fileName);
        
    temp=textscan(fid,'%f %f','headerlines',0);
    fclose(fid);
    wavelength{fileInd} = temp{1};
    spectra{fileInd} = temp{2};
end
end