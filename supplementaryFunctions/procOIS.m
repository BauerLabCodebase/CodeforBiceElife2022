function datahb = procOIS(rawdata, diffPath, extCoeff, varargin)

% (c) 2009 Washington University in St. Louis
% All Rights Reserved

%   Inputs:
%
%   rawdata = n x n x (LED channels) x time. Unit = same as baseline.
%   baseline = n x n x (LED channels). Baseline light intensity from which
%   rawdata fluctuates. Unit = same as rawdata.
%   diffPath = (LED channels) x 1. Differential pathlength for each light
%   source. Unit = cm
%   extCoeff = (LED channels) x 2. Usually prahl extinction coefficients for each light source is
%   used. Unit = cm^(-1) * M^(-1)
%  
    %mask (optional) = brain mask. If not given, then the whole image is considered
%   part of the brain.
%
%   Content:
%
%   Based on Beer-Lambert law, the change in concentration of hemoglobin
%   species is calculated. Hemoglobin concentration change is calculated
%   for each spatial pixel independently. Raw data is divided by baseline,
%   then placed within negative natural log function (due to exponential
%   part of Beer-Lambert law equation).
%
%   Output:
%   datahb = n x n x 2 x time. Hemoglobin fluctuations. Unit = M
%
% (c) 2019 Washington University in St. Louis
% All Right Reserved
%
% Licensed under the Apache License, Version 2.0 (the "License");
% You may not use this file except in compliance with the License.
% A copy of the License is available is with the distribution and can also
% be found at:
%
% http://www.apache.org/licenses/LICENSE-2.0
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE, OR THAT THE USE OF THE SOFTWARD WILL NOT INFRINGE ANY PATENT
% COPYRIGHT, TRADEMARK, OR OTHER PROPRIETARY RIGHTS ARE DISCLAIMED. IN NO
% EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
% OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
% HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
% STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
% ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

% p = inputParser;
% addOptional(p, 'mask', [], @islogical);
% parse(p,varargin(:));

if numel(varargin) > 0
    mask = varargin{1};
else
    mask = true(size(rawdata,1), size(rawdata,2));
end

if size(diffPath,2) ~= 1
    diffPath = diffPath';
end

%% Process raw data

rawdata(rawdata < 0) = 0;
nVx = size(rawdata,2);
nVy = size(rawdata,1);

rawdataReshaped = reshape(rawdata, [size(rawdata,1)*size(rawdata,2) size(rawdata,3) size(rawdata,4)]);
BaselineFunction  = @(x) mean(x,numel(size(x)));
baseline = BaselineFunction(rawdata);
baselineReshaped = reshape(baseline, [size(baseline,1)*size(baseline,2) size(baseline,3)]);

logData = -log(bsxfun(@rdivide,rawdataReshaped,baselineReshaped));
datahb = zeros(nVy*nVx,2,size(rawdataReshaped,3));
for ind = 1:nVx*nVy
    if mask(ind) 
        datahb(ind,:,:) = procPixel(squeeze(logData(ind,:,:)), ...
            diffPath, extCoeff);
    end
end
datahb = reshape(datahb, nVy, nVx, size(datahb,2), size(datahb,3));

end

%% procPixel()
function [output]=procPixel(logData, distance, extCoeff)

% logData = (light source num) x (time)
% extCoeff = (light source num) x (species num)
% distance = (light source num) x 1
% output = (species num) x (time)

% (light source num) x time

% % denominator = log(10) * extinction coeff * distance
% denominator = bsxfun(@times, log(10)*extCoeff, distance);
% % (light source num) x (species num)
%
% %Spectroscopy
% output=dotspect(dataLog2Baseline, denominator);

for c = 1:size(logData,1)
    logData(c,:) = logData(c,:)/distance(c);
end

% Spectroscopy
output = dotspect(logData, log(10)*extCoeff);
end