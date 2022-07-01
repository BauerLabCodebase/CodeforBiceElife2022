function fcData = seedFC_fun(data,roi)
% seedFC outputs map of FC to seed
%   inputs:
%       data = 3D matrix. (spatial x spatial x time)
%       roi = 3D Boolean matrix. (spatial x spatial x seeds). Each image,
%       for pixels that are true, are considered as part of that seed.

%% fc
seedNum = size(roi,3);
fcData = nan(seedNum);

data = reshape(data,[],size(data,3));

seedData = nan(size(data,2),seedNum);
for seed = 1:seedNum
    seedData(:,seed) = nanmean(data(squeeze(roi(:,:,seed)),:),1);
end

for seed1 = 1:seedNum
    for seed2 = 1:seedNum
        fcData(seed1,seed2) = corr(seedData(:,seed1),seedData(:,seed2));
    end
end

end