function fcData = bilateralFC_fun(data)
% regionalFC finds the connectivity of the ROI with the rest
%   inputs:
%       data = 3D matrix. (spatial x spatial x time)
%   output:
%       fcData = 2D (spatial x spatial)

spatialDim = size(data); spatialDim = spatialDim(1:2);

colMiddle = floor(spatialDim(2)/2);
fcData = nan(spatialDim);
for pixRow = 1:spatialDim(1) % for each pixel
    for pixCol = 1:spatialDim(2)
        pixColOpposite = spatialDim(2) - pixCol + 1;
        if pixCol <= colMiddle
            data1 = squeeze(data(pixRow,pixCol,:));
            data2 = squeeze(data(pixRow,pixColOpposite,:));
            fcData(pixRow,pixCol) = corr(data1,data2);
            
        else % upper triangle
            fcData(pixRow,pixCol) = fcData(pixRow,pixColOpposite);
        end
    end
end
end