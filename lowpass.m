function [fdata]=lowpass(data,omegaHz,frate)

% lowpass() low-pass filters data, preserving phase information. Syntax:
% 
% [fdata]=lowpass(data,omegaHz,framerate)
% 
% data can be an array of any size, as long as time is the last dimension.
% If data is a struct, then every field is filtered. omegaHz is the cut-off
% frequency of the filter (in Hz). framerate is the framerate of your data
% (in Hz). 
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
% from OIS repo
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

    % Reshape to Stuff x Time
    [data2 Sin Sout]=datacondition(data,1);

    % Initialize
    fdata=zeros(Sout);
    
    % Convert Hz Frequency to a Fraction of the Nyquist Frequency
    omegaNy=omegaHz*(2/frate);
    
    % Make Filter
    [b,a] = butter(5,omegaNy);
    
    % Filter every time trace (w/ phase preservation)
    for n=1:Sout(1)
        fdata(n,:)=filtfilt(b,a,squeeze(data2(n,:)));
    end
    
    fdata=reshape(fdata,Sin);


end

function [data2, Sin, Sout]=datacondition(data,trail)

% datacondition is a program used by many filtering and imaging programs so
% that they don't need to know the exact format of the input data. For
% example, we want lowpass() to be able to handle data input as either
% source x detector x color x time, optode pair x color x time, or x-voxels
% x y-voxels x Hb x time. In each case, lowpass() should only care about
% time (the last dimension) and loop over all the preceding dimensions.
% datacondition  solves this problem by reshaping input data into the
% format: dimension-for-looping x relevant dimensions, where every
% dimension that needs to be looped over has been reshaped into a single
% dimension.
% 
% The relevant dimensions to be operated on are called the "trailing
% dimensions". Usually the relevant dimension is time, however some
% programs also need to explicitly loop over color (or Hb). Thus, you can
% tell datacondition whether to leave one trailing dimension (time) or two
% trailing dimensions (color then time).
% 
% The syntax is:
% 
% >> [data2 Sin Sout]=datacondition(data,trail)
% 
% data is the input data. trail is the number of dimensions to be left
% unchanged (i.e., trail=1 for time, and trail=2 for color and time). data2
% is the data reshaped by datacondition to have one leading dimension and
% trail other dimensions. Sin is the original shape of data. This allows
% the program calling datacondition to reshape its output back to the
% original shape of data. Sout is the shape of data.

% Get size of input data
Sin=size(data);
L=length(data); % longest dimension (presumably time)
N=numel(data); % total number of elements

% Special case: row/column vector
if L==N
    Sout=Sin;
    if Sin(1)==L % if time is first
        data2=data'; % flip
        Sout=fliplr(Sout);
    else
        data2=data;
    end
    return
end

% Otherwise, assume time last, color 2nd-to-last, etc., reshape rest
if numel(Sin)<trail % if too many dimensions requested
    error('** You can not have more trailing dimensions than available dimensions **')
elseif numel(Sin)==trail % if already has requested dimensionality, then no change
    Sout=Sin;
else % else reshape leading dimensions into one
    Sout=ones(1,1+trail);
    Sout(1)=prod(Sin(1:(end-trail)));
    for n=0:(trail-1)
        Sout(end-n)=Sin(end-n);
    end
end

data2=reshape(data,Sout);

end