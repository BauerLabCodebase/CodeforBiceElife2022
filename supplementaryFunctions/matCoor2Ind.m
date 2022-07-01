function ind = matCoor2Ind(coor,matSize)
%matCoor2Ind Summary of this function goes here
%   Inputs:
%       coor = m x n where m is number of points and n is number of
%       coordinates per point
%       matSize = matrix size

subMatSize = nan(numel(matSize),1);
subMatSize(1) = 1;
for dim = 2:numel(subMatSize)
    subMatSize(dim) = prod(matSize(1:dim-1));
end

ind = coor(:,1);
for dim = 2:numel(subMatSize)
    ind = ind + (coor(:,dim)-1)*subMatSize(dim);
end

end

