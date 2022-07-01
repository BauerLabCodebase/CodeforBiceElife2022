function [gsrData, gs, beta] = gsr(data,isbrain)

% Performs global signal regression from every pixel.
% Inputs:
%   data are (n x n x species x time) or (n x n x time)
%   isbrain is a binary mask for all pixels labeld as brain.
% Outputs:
%   gsrData = gsr signal
%   gs = global signal
%   beta = regression coefficient, describing how much gs was in the signal
%   before being regressed out

% (c) 2009 Washington University in St. Louis
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


isbrain = logical(isbrain);
isbrain = isbrain(:);

origSize = size(data);

data = reshape(data, numel(isbrain), [], origSize(end));
gs = squeeze(nanmean(data(isbrain(:), :, :), 1));
[regressedData, ~, beta]= regcorr(data(isbrain(:), :, :), gs);

% reshaping to original format
gsrData = zeros(size(data));
gsrData(isbrain(:), :, :) = regressedData;
gsrData = reshape(gsrData,origSize);
end