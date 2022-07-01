function info = sysInfo(systemType)
%session2procInfo Making OIS preprocess info from session type
%   Input:
%       sessiontype = char array showing type of systemtype ('fcOIS1','fcOIS2')
%   Output:
%       info = struct with info such as rgb indices
%           rgb = 1x3 vector specifying indices for red, green, and blue
%           numLEDs = number of leds
%           LEDFiles = string array containing name of text files showing
%           LED spectra
%           readFcn = function handle for reading from raw file (tiff, dat)
%           invalidFrameInd = any temporal frame index that should be
%           removed prior to processing (these are any indices that are not
%           dark frames yet still need to be removed)
%           gbox = gaussian filter box size for smoothing image
%           gsigma = gaussian filter sigma for smoothing image

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

if strcmp(systemType,'EastOIS1')
    info.rgb = [4 2 1];
    info.numLEDs = 4;
    info.binFactor = [1 1 1 1];
    info.LEDFiles = {'East3410OIS1_TL_470_Pol.txt', ...
        'East3410OIS1_TL_590_Pol.txt', ...
        'East3410OIS1_TL_617_Pol.txt', ...
        'East3410OIS1_TL_625_Pol.txt'};
    info.FADFiles = [];
    info.fluorFiles = {};
    info.chHb = 1:4;
    info.chFluor = [];
    info.chFAD = [];  
    info.chLaser = [];
    info.chSpeckle = [];
    info.numInvalidFrames = 1;
    info.validThr = [1 16382];% remove
    info.gbox = 5;
    info.gsigma = 1.2;
    info.Contrasts={'HbO','HbR','HbT'};    
    info.colors = {'r','b','k'};
elseif strcmp(systemType,'EastOIS1+laser')
    info.rgb = [4 2 1];
    info.numLEDs = 5;
    info.binFactor = [1 1 1 1 1];
    info.LEDFiles = {'East3410OIS1_TL_470_Pol.txt', ...
        'East3410OIS1_TL_590_Pol.txt', ...
        'East3410OIS1_TL_617_Pol.txt', ...
        'East3410OIS1_TL_625_Pol.txt'};
    info.FADFiles = [];
    info.fluorFiles = {};
    info.chHb = 1:4;
    info.chFluor = [];
    info.chFAD = [];        
    info.chSpeckle = [];
    info.chLaser = 5;
    info.numInvalidFrames = 1;
    info.validThr = [1 16382];
    info.gbox = 5;
    info.gsigma = 1.2;
    info.Contrasts={'HbO','HbR','HbT','Laser'};
    info.colors = {'r','b','k'};
elseif strcmp(systemType,'EastOIS1+fluor+speckle')
    info.rgb = [4 2 NaN];
    info.numLEDs = 5;
    info.binFactor = [4 4 4 4 1];
    info.LEDFiles = {'M470nm_SPF_pol.txt',...
        'TL_530nm_515LPF_Pol.txt', ...
        'East3410OIS1_TL_617_Pol.txt',...
        'East3410OIS1_TL_625_Pol.txt'};
    info.fluorFiles = {'gcamp6f_emission.txt'};
    info.FADFiles = [];
    info.chHb = 2:4;
    info.chFluor = 1;
    info.chSpeckle = 5;
    info.chLaser = [];
    info.chFAD = [];        
    info.numInvalidFrames = 1;
    info.validThr = [1 16382];
    info.gbox = 5;
    info.gsigma = 1.2;
    info.Contrasts={'HbO','HbR','HbT','Calcium','CBF'};    
    info.colors = {'r','b','k','g','c'};    
elseif strcmp(systemType,'EastOIS1_FAD')
 info.rgb = [4 2 NaN];
    info.numLEDs = 4;
    info.binFactor = [1 1 1 1];
    info.LEDFiles = {'M470nm_SPF_pol.txt', ...
        'TL_530nm_515LPF_Pol.txt', ...
        'East3410OIS1_TL_617_Pol.txt', ...
        'East3410OIS1_TL_625_Pol.txt'};
    info.fluorFiles = {};
    info.FADFiles = {'fad_emission.txt'};
    info.chHb = 2:4;
    info.chFluor = [];
    info.chFAD = 1;
    info.chSpeckle = [];
    info.chLaser = [];
    info.numInvalidFrames = 1;
    info.validThr = [1 16382];
    info.gbox = 5;
    info.gsigma = 1.2;
    info.Contrasts={'HbO','HbR','HbT','FAD'};
    info.colors = {'r','b','k','g'};     
elseif strcmp(systemType,'EastOIS1_GCaMP')
    info.rgb = [4 2 NaN];
    info.numLEDs = 4;
    info.binFactor = [1 1 1 1];
    info.LEDFiles = {'M470nm_SPF_pol.txt', ...
        'TL_530nm_515LPF_Pol.txt', ...
        'East3410OIS1_TL_617_Pol.txt', ...
        'East3410OIS1_TL_625_Pol.txt'};
    info.fluorFiles = {'gcamp6f_emission.txt'};
    info.FADFiles = []; 
    info.chHb = 2:4;
    info.chFluor = 1;
    info.chFAD = [];
    info.chSpeckle = [];
    info.chLaser = [];
    info.numInvalidFrames = 1;
    info.validThr = [1 16382];
    info.gbox = 5;
    info.gsigma = 1.2;
    info.Contrasts={'HbO','HbR','HbT','Calcium'};  
    info.colors = {'r','b','k','g'};
elseif strcmp(systemType,'EastOIS2_FAD_RGECO')
    info.rgb = [4 2 NaN];
    info.numLEDs = 4;
    info.binFactor = [4 4 4 4];
    info.LEDFiles = [
            "TwoCam_Mightex470_BP_Pol.txt",...
            "TwoCam_Mightex525_BP_Pol_500-580.txt", ...
            "TwoCam_Mightex525_BP_Pol.txt",...
            "TwoCam_TL625_Pol_Longer593.txt"];
    info.fluorFiles = {'jrgeco1a_emission.txt'};
    info.FADFiles = {'fad_emission.txt'};    
    info.chHb = [2 4];
    info.chFluor = 3; %this means channel calcium!!
    info.chFAD = 1;
    info.chSpeckle = [];
    info.chLaser = [];
    info.numInvalidFrames = 1;
    info.validThr = [1 inf];
    info.gbox = 5;
    info.gsigma = 1.2;
    info.Contrasts={'HbO','HbR','HbT','Calcium','FAD'};
    info.colors = {'r','b','k','m','g'};
    info.cam1Chan = [1 2];
    info.cam2Chan = [3 4];
elseif strcmp(systemType,'EastOIS2+laser')
    info.rgb = [2 1 NaN];
    info.numLEDs = 4;
    info.binFactor = [4 4 4 4];
    info.LEDFiles = [     
            "TwoCam_Mightex525_BP_Pol_500-580.txt", ...
            "TwoCam_TL625_Pol_Longer593.txt",...
            "TwoCam_Mightex525_BP_Pol.txt"];
    info.fluorFiles = {'jrgeco1a_emission.txt'};
    info.FADFiles = [];  
    info.chHb = [1 2];
    info.chFluor = 3; %this means channel calcium!!
    info.chFAD = [];
    info.chSpeckle = [];
    info.chLaser = 4;
    info.numInvalidFrames = 1;
    info.validThr = [1 inf];
    info.gbox = 5;
    info.gsigma = 1.2;
    info.Contrasts={'HbO','HbR','HbT','Calcium','Laser'};
    info.colors = {'r','b','k','m','c'};
    info.cam1Chan = [1 4];
    info.cam2Chan = [2 3];
end

paramPath = what('bauerParams'); % path to bauerParams module
sourceSpectraLoc = fullfile(paramPath.path,'ledSpectra'); % path to led spectra text files
for ledInd = 1:numel(info.LEDFiles)
    info.LEDFiles{ledInd} = fullfile(sourceSpectraLoc,info.LEDFiles{ledInd});
end
fluorSpectraLoc = fullfile(paramPath.path,'probeSpectra'); % path to fluor spectra text files
for chInd = 1:numel(info.fluorFiles)
    info.fluorFiles{chInd} = fullfile(fluorSpectraLoc,info.fluorFiles{chInd});
end


if ~isempty(info.FADFiles)
for chInd = 1:numel(info.FADFiles)
    info.FADFiles{chInd} = fullfile(fluorSpectraLoc,info.FADFiles{chInd});
end
end

