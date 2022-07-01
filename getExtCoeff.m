function [lambda, extCoeff] = getExtCoeff(extCoeffFile)
% getExtCoeff takes in text file with first column being frequency of
% light, and the other columns being extinction coefficient of each species. (unit is cm-1/M). Output is
% unit of (cm-1/M)

data=dlmread(extCoeffFile);

speciesNum = size(data,2);
lambda = data(:,1);
extCoeff = squeeze(data(:,2:speciesNum));

end