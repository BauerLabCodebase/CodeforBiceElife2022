function [whole_spectra_map,... Each pixel has a power spectra (128,128,hz)
    avg_cort_spec,...    %Average over all of the pixels (hz)
    powerMap,hz,...                 integrated spectra for each pixel (size 128,128,3)
    global_sig_for,glob_sig_power]... averaged signal of all pixles and associated FFt of that
    = PowerAnalysis(data,framerate,mask,varargin)

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

if numel(varargin) > 0
    fft_bool=varargin{1};
    freqRange={[0.01,0.08],[0.5 ,4],[0 framerate/2]}; %this function runs for 3 frequency bands    
elseif numel(varargin) > 1
    freqRange = varargin{1};
    fft_bool=varargin{2};
    disp('hi')
else %DEFAULT SETTINGS!
    freqRange={[0.01,0.08],[0.5 ,4],[0 framerate/2]}; %this function runs for 3 frequency bands
    fft_bool=0; %Don't use FFT
end


%Initialize
glob_sig_power=nan(1,3);
data=data.*mask;
nVy = size(data,1);
nVx = size(data,2);
data(isnan(data)) = 0;
powerMap = nan(nVy,nVx,3);
data1 = transpose(reshape(data,nVx*nVy,[]));
%% Pwelch method (power spectral density estimate)
if fft_bool==0
    [Pxx,hz] = pwelch(data1,[],[],[],framerate); %returns 128*128*length(hz). AKA spectra for each pixel
    Pxx = Pxx';
    Pxx = reshape(Pxx,nVy,nVx,[]);
else %Use FFT isntead (https://www.mathworks.com/help/signal/ug/power-spectral-density-estimates-using-fft.html)
    N=size(data1,1);
    xdft=fft(data1);
    xdft = xdft(1:N/2+1,:);
    Pxx= (1/(framerate*N)) * abs(xdft).^2;
    Pxx(2:end-1,:) = 2*Pxx(2:end-1,:); % In order to conserve the total power, multiply all frequencies that occur in both sets — the positive and negative frequencies — by a factor of 2
    hz = 0:framerate/size(data1,1):framerate/2;
    Pxx=reshape(Pxx',[128,128,size(Pxx,1)]);
end

whole_spectra_map=Pxx; %now size 128,128,length(hz)
avg_cort_spec=mean(reshape(whole_spectra_map,[size(whole_spectra_map,1)*size(whole_spectra_map,2),size(whole_spectra_map,3)]),1,'omitnan')';


[~,start_freq.isa]=min(abs(hz-freqRange{1}(1))); %This is finding closest index value to the cutoff frequencies
[~,end_freq.isa]=min(abs(hz-freqRange{1}(2)));

[~,start_freq.delta]=min(abs(hz-freqRange{2}(1))); %This is finding closest index value to the cutoff frequencies
[~,end_freq.delta]=min(abs(hz-freqRange{2}(2)));

[~,start_freq.full]=min(abs(hz-freqRange{3}(1))); %This is finding closest index value to the cutoff frequencies
[~,end_freq.full]=min(abs(hz-freqRange{3}(2)));


%Power Maps (intergrate over the freq band. I do this by summing and multiplying by deltaHz. Same as kenny)
for kk = 1:nVy
    for ll=1:nVx
        powerMap(kk,ll,2) = (hz(2)-hz(1))*sum(Pxx(kk,ll,start_freq.isa: end_freq.isa));
        powerMap(kk,ll,3) = (hz(2)-hz(1))*sum(Pxx(kk,ll,start_freq.delta: end_freq.delta));
        powerMap(kk,ll,1) = (hz(2)-hz(1))*sum(Pxx(kk,ll,start_freq.full: end_freq.full));
    end
end

%Global Signal Power Pwelsh (i.e., AVERAGE signal and then power, |fft(mean(x,y))]| )
glob_sig=mean(reshape(data,[size(data,1)*size(data,2),size(data,3)]),1,'omitnan')';
if fft_bool==0
    [global_sig_for,hz]=pwelch(glob_sig,[],[],[],framerate);
else
    N=size(glob_sig,2);
    xdft=fft(glob_sig);
    xdft = xdft(1:N/2+1);
    global_sig_for= (1/(framerate*N)) * abs(xdft).^2;
    global_sig_for(2:end-1,:) = 2*global_sig_for(2:end-1,:);
    hz = 0:framerate/N:framerate/2;
end

glob_sig_power(:,2)=(hz(2)-hz(1))*sum(global_sig_for(start_freq.isa:end_freq.isa))';
glob_sig_power(:,3)=(hz(2)-hz(1))*sum(global_sig_for(start_freq.delta:end_freq.delta))';
glob_sig_power(:,1)=(hz(2)-hz(1))*sum(global_sig_for(start_freq.full:end_freq.full))';



end


