function dp = diffPath(c,musp,extCoeff,conc)
%diffPathFac Finds differential pathlength
%   Inputs:
%       c = speed of light in medium
%       musp = reduced scattering coefficient
%       extCoeff = extinction coefficient for each material (1 x # species)
%       conc = concentration of each material (1 x # species)
%   Output:
%       dp = differential pathlength

% Absorption Coeff.
mua = log(10)*conc*extCoeff';

% Diffusion Coefficient
gamma = sqrt(c) ./ sqrt(3 * (mua + musp));

% calculate differential pathlength factor
% dpf = 1./sqrt(3*mua*(mua+musp));

dp = (c/musp)*(1./(2*gamma.*sqrt(mua*c))).*(1+(3/c).*mua.*gamma.^2);
end

