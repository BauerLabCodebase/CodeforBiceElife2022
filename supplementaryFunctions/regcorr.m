function [data2, R, betaOut]=regcorr(data,hem)

% regcorr() regresses out a signal from data and returns the
% post-regression data as well as the correlation coefficient of the input
% regressor with every channel in the data. If y_{r} is the signal to be
% regressed out and y_{in} is a data time trace (either source-detector or
% imaged), then the output is the least-squares regression: y_{out} =
% y_{in} - y_{r}(<y_{in},y_{r}>/|y_{r}|^2). Additionally, the correlation
% coefficient is given by: R=(<y_{in},y_{r}>/(|y_{in}|*|y_{r}|)).
% 
% To use regcorr() The syntax is:
% 
% [data2 R beta]=regcorr(data,hem)
% 
% regcorr() takes two input variables data and hem. This first variable is
% your data from which you want the signal regressed. It must be an array
% of two or more dimensions. The last dimension must be time, and the
% second-to-last dimension must be color/contrast. The other dimensions can
% be arranged in any order (e.g., source by detector, optode pair, or
% voxels). regcorr() will then loop over these dimensions as well as the
% color/contrast dimension.
% 
% The second input variable is signal which you want regressed from all the
% measurements. It must be a two dimensional array with the first dimension
% being color/contrast, and the second being time. If there is more than
% one color/contrast (e.g., 750 nm and 850 nm), then the number of
% contrasts in hem must be the same as in data. In this case, the
% regression will be contrast-matched, where each color in data will have
% that specific color's noise regressed out. If hem has only one contrast
% (i.e., one row), then that time trace will be regressed out of every
% contrast in data.
% 
% regcorr() outputs the variable data2, which is the regressed data. This
% returned variable has the same array size as the input variable. The
% second output variable is the correlation coefficients with every
% channel. It has the same size as the input data array (except without the
% time dimension). The second output, R is the correlation coefficient
% between hem and every time trace in data (within a color/contrast). The
% third output, beta, is the regression coefficient for each source
% (detector, voxel, etc.). 

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

[data, Sin, Sout]=datacondition(data,2); % reshape to meas x color x time
[hem, Hin, Hout]=datacondition(hem,2); % reshape to color x time

% check compatibility
if Hout(end)~=Sout(end)
    error('** Your data and regressor do not have the same time length: perhaps check your Resampling Tolerance Flag **')
end

betaOut = [];

if numel(Sout)==3 % normal case
    L=Sout(1);
    C=Sout(2);
    T=Sout(3);
    
    data2=zeros(T,C,L);
    R=zeros(L,C);
    
    for c=1:C
        temp=squeeze(data(:,c,:))'; % get single color/contrast time x voxel
        g=hem(c,:)'; % regressor/noise signal in correct orientation time x 1
        gp=pinv(g); % pseudoinverse for least-square regression 1 x time
        beta=gp*temp; % regression coefficient 1 x voxel
        betaOut = [betaOut; beta];
        data2(:,c,:)=temp-g*beta; % linear regression
        R(:,c)=normRow(g')*normCol(temp); % correlation coefficient
    end
    data2=permute(data2,[3 2 1]); % switch dimensions back to correct order
    R=reshape(R,Sin(1:(end-1))); % reshape to original size (minus time)
    
elseif numel(Sout)==2 % special case of one data trace
    C=Sout(1);
    T=Sout(2);

    data2=zeros(C,T);
    R=zeros(1,C);
    
    for c=1:C
        temp=squeeze(data(c,:))';
        
        g=hem(c,:)';
        gp=pinv(g);
        beta=gp*temp;
        betaOut = [betaOut; beta];
        data2(c,:)=temp-g*beta;
        
        R(c)=normRow(g')*normCol(temp);
    end
    
end

data2=reshape(data2,Sin); % reshape to original shape

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

function n = normRow(m)

% normRow normalizes the rows in a 2D matrix. That is that is takes every
% row in the matrix and divides it by it's norm, so that that row vector
% will now have a norm of 1. Syntax:
% 
% normM=normRow(M)

[mr,mc]=size(m);

v=sqrt(sum((m.*m),2));

n=m./repmat(v,1,mc);

end

function n = normCol(m)

% normCol normalizes the columns in a 2D matrix. That is that is takes
% every column in the matrix and divides it by it's norm, so that that
% column vector will now have a norm of 1. Syntax:
% 
% normM=normCol(M)

[mr,mc]=size(m);

v=sqrt(sum((m.*m),1));

n=m./repmat(v,mr,1);

end