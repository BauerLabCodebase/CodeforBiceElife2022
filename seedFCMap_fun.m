function fcData = seedFCMap(data,roi)
% seedFC outputs map of FC to seed
%   inputs:
%       data = 3D matrix. (spatial x spatial x time)
%       roi = Boolean 2D matrix

%% fc

roi = roi(:);

ySize = size(data,1);
xSize = size(data,2);

data = reshape(data,[],size(data,3));
roiData = nanmean(data(roi,:),1)';
%normr(roiData*data') convert corr way to easy-bauer way

fcData = corr(roiData,data');
fcData = reshape(fcData,ySize,xSize);

end


