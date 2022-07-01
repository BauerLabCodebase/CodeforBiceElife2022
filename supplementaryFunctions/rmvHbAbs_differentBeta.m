function [fluorDataHbRemoved, fraction] = rmvHbAbs_differentBeta(fluorData,hbOData,hbRData,hbOExtCoeff,hbRExtCoeff,wavelength1Path,wavelength2Path,alpha,beta)
%rmvHbAbs Removes absorption by hemoglobin
%   Inputs:
%       fluorData = 1D fluorescence data
%       hbOData = 1D HbO change data
%       hbRData = 1D HbR change data
%       hbOExtCoeff = 1x2 HbO extinction coefficient for two wavelengths
%       hbRExtCoeff = 1x2 HbR extinction coefficient for two wavelengths
%       wavelength1Path = constant. pathlength for first wavelength
%       wavelength2Path = constant. pathlength for second wavelength
%   Outputs:
%       fluorDataHbRemoved = 1D fluorescence data with Hb effect removed
%       fraction = ratio of fluorescence with Hb removed compared to
%       original

muWav1 = log(10)*hbOData*hbOExtCoeff(1) + log(10)*hbRData*hbRExtCoeff(1); % absorption coefficient with hemoglobin amount taken into account
muWav2 = log(10)*hbOData*hbOExtCoeff(2) + log(10)*hbRData*hbRExtCoeff(2);

exponent = alpha*muWav1*wavelength1Path + beta*muWav2*wavelength2Path;

fraction = exp(exponent);

fluorDataHbRemoved = fluorData.*fraction;

end