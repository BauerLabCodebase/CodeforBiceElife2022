function coor = circleCoor(centerCoor,radius)
%circleCoor Generates coordiates that are within a circle
%   Input:
%       centerCoor = center coordinate (2 elements)
%       radius = 1 number
%   Output:
%       coor = nx2 output

[candidateCoorX, candidateCoorY] = meshgrid(centerCoor(1)-radius:centerCoor(1)+radius,...
    centerCoor(2)-radius:centerCoor(2)+radius);

candidateCoorX = candidateCoorX(:);
candidateCoorY = candidateCoorY(:);

validPix = false(numel(candidateCoorX),1);
for pix = 1:numel(candidateCoorX)
    dist = sqrt((candidateCoorX(pix) - centerCoor(1))^2+(candidateCoorY(pix) - centerCoor(2))^2);
    if dist <= radius
        validPix(pix) = true;
    end
end

coor = [candidateCoorX(validPix) candidateCoorY(validPix)];

end

