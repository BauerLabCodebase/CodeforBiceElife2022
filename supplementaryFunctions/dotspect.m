function concentration = dotspect(datamua,E)

% dotspect() performs spectroscopy on DOT <math>\frac{}{}\mu_a</math> data.
% 
% [concentration]=dotspect(datamua,E)
% 
% datamua is your absorption data, which must have a second-to-last
% dimension of color/wavelength. E is the spectroscopy matrix to use, which
% has dimensions wavelength x Hb contrast. If E is a square matrix, then
% the spectroscopy is performed with a simple matrix inversion. If E asks
% for fewer contrasts than there are wavelengths, then dotspect() should do
% a least-squares fitting, although this has never been tested. If there
% are more contrasts than wavelengths, the problem is obviously impossible
% to solve, resulting in an error. 
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
% OIS repo
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

[Cin, Cout] = size(E);

dataSize = size(datamua);
sourceNum = dataSize(end-1);
tNum = dataSize(end);

if sourceNum ~= Cin
    error('The extinction coefficients given do not match the number of light sources');
end
if dataSize(end-1) == 1
    error('** Your data must have more than one wavelength to perform spectroscopy **');
end
if Cout > Cin
    error('** Your spectroscopy problem is underdetermined **');
end

datamua = reshape(datamua,[],sourceNum,tNum);

if Cout==Cin % matrix inversion
    iE=inv(E);
else
    iE=pinv(E);
end

concentration = nan(size(datamua,1),Cout,tNum);

for pix = 1:size(datamua,1)
    for h = 1:Cout
        tseq = zeros(tNum,1);
        for c = 1:Cin
            tseq = tseq + iE(h,c)*squeeze(datamua(pix,c,:));
        end
        concentration(pix,h,:) = tseq;
    end
end

concentration = reshape(concentration,[dataSize(1:end-3) Cout tNum]);
end