function [row,col] = ind2D(index,matSize)
%ind2D Converts index of 2D matrix to 2D coordinates
%   Inputs:
%       index = index of data in vector
%       matSize = 2 values referring to size of 2 dimensions
%   Outputs:
%       row = first dim ind
%       col = second dim ind

col = ceil(index/matSize(1));
row = (mod(index-1,matSize(1))+1);
end

