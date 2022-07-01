function dp = diffPath(c,musp,extCoeff,conc)
%diffPathFac Finds differential pathlength
%   Inputs:
%       c = speed of light in medium
%       musp = reduced scattering coefficient
%       extCoeff = extinction coefficient for each material (1 x # species)
%       conc = concentration of each material (1 x # species)
%   Output:
%       dp = differential pathlength

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

% Absorption Coeff.
mua = log(10)*conc*extCoeff';

% Diffusion Coefficient
gamma = sqrt(c) ./ sqrt(3 * (mua + musp));

% calculate differential pathlength factor
% dpf = 1./sqrt(3*mua*(mua+musp));

dp = (c/musp)*(1./(2*gamma.*sqrt(mua*c))).*(1+(3/c).*mua.*gamma.^2);
end

