function [spectra, wavelength]=getSpectra(fileNames)
% getSourceSpectra Obtains spectral information of light sources from their
% text files
%   Inputs:
%       fileNames = cell array of char vectors
%   Outputs:
%       spectra = cell array containing spectrum, which is variable containing
%       LED intensity at certain wavelength;
%       wavelength = cell array containing wavelength

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