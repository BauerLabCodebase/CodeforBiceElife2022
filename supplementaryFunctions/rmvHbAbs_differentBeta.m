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

muWav1 = log(10)*hbOData*hbOExtCoeff(1) + log(10)*hbRData*hbRExtCoeff(1); % absorption coefficient with hemoglobin amount taken into account
muWav2 = log(10)*hbOData*hbOExtCoeff(2) + log(10)*hbRData*hbRExtCoeff(2);

exponent = alpha*muWav1*wavelength1Path + beta*muWav2*wavelength2Path;

fraction = exp(exponent);

fluorDataHbRemoved = fluorData.*fraction;

end