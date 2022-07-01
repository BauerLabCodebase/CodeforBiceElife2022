function filtData = filterData(data,fMin,fMax,sR,varargin)
%filterData Band-pass filters data
%   data = nD matrix. last dim is time
%   fMin = minimum frequency
%   fMax = maximum frequency
%   sR = sampling rate

if numel(varargin)>0
    isbrain=varargin{1};
    isbrain=double(isbrain);
    data=data.*isbrain;
end


data(isnan(data))=0;
data(isinf(data))=0;

originalSize = size(data);

% vectorizes data into n x time
data = reshape(data,[],originalSize(end));

% initializes filtered data
filtData = zeros(size(data));

% filters for each pixel
for pixel = 1:size(data,1)
    if ~ (sum(data(pixel,:).^2)==0) || ~(sum(isnan(data(pixel,:)))==0) %ignore outside of brain (works if mask is nan or 0)
        
    ind = [1 size(data,2)];
    % select the data. Edges are considered to reduce edge effects.
    edgeLength = round(sR/fMin/2); % consider at least half the wavelength
    [selectedData, realInd, ~] = selectWithEdges(squeeze(data(pixel,:)),ind,edgeLength);
    
    % filter
    filtDataTemp = highpass(selectedData,fMin,sR);
    filtDataTemp = lowpass(filtDataTemp,fMax,sR);
    filtDataTemp = filtDataTemp(realInd(1):realInd(2));
    
    filtData(pixel,:) = filtDataTemp;
    
    end
    
end

% reshapes back into original shape
filtData = reshape(filtData,originalSize);
end

