function [result,validPixels] = affineTransform(inputData,affineMarkers)
%affineTransform Affine transform data so that location of
%anatomical parts are standardized.
% Inputs:
%   inputData = 4D matrix. 1st dim is y, 2nd dim is x, 3rd dim is species, 4th
%   dim is time.
%   affineMarkers = struct containing bregma, tent, and OF locations.
% Outputs:
%   result = 4D matrix affine transformed
%   validPixels = logical matrix showing which pixels have valid data
%
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

spatialSize = [size(inputData,1) size(inputData,2)];

% normalize affine markers if it isn't already
if affineMarkers.bregma(1) > 1
    affineMarkers.bregma = affineMarkers.bregma./spatialSize;
    affineMarkers.tent = affineMarkers.tent./spatialSize;
    affineMarkers.OF = affineMarkers.OF./spatialSize;
end

inputData(isinf(inputData)) = 0;
inputData(isnan(inputData)) = 0;

sample = ones(size(inputData,1),size(inputData,2));
sample = affine(affineMarkers, sample);
validPixels = sample > 1 - 10*eps;
tObj = affineMarker2affine2d(spatialSize,affineMarkers);
refObj = imref2d(spatialSize);

result = imwarp(inputData,tObj,'OutputView',refObj);
if islogical(inputData)
    result = logical(result);
else
    result = real(result);
end

end