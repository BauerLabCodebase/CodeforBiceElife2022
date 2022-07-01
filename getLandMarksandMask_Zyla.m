function [isbrain,xform_isbrain,I,seedcenter,WLcrop,xform_WLcrop,xform_WL] = getLandMarksandMask_Zyla(WL)
% loads mask file in and outputs white light image while getting landmarks
% for affine transform

[I, seedcenter]=MakeSeedsMouseSpace(WL);

disp('Create mask')
mask=roipoly(WL);

if ~any(any(mask))
    load('D:\OIS_Process\Paxinos\AtlasandIsbrain.mat', 'parcelisbrainPS');
    isbrain=InvAffine(I, parcelisbrainPS, 'New');
    isbrain=single(uint8(isbrain));
    [xform_isbrain]=affineTransform(isbrain,I);
    xform_isbrain=single(uint8(xform_isbrain));
    
    [xform_WL]=affineTransform(WL,I);
    
    for j=1:3
        xform_WLcrop(:,:,j)=xform_WL(:,:,j).*parcelisbrainPS; %make affine transform WL image
    end
    
    WLcrop=WL;
    for j=1:3
        WLcrop(:,:,j)=WLcrop(:,:,j).*isbrain; %make WLcrop image
    end
    
else
    
    isbrain=single(uint8(mask));
    [xform_isbrain]=affineTransform(isbrain,I);
    xform_isbrain=single(uint8(xform_isbrain));
    
    [xform_WL]=affineTransform(WL,I);
    
    for j=1:3
        xform_WLcrop(:,:,j)=xform_WL(:,:,j).*xform_isbrain; %make affine transform WL image
    end
    
    WLcrop=WL;
    for j=1:3
        WLcrop(:,:,j)=WLcrop(:,:,j).*isbrain; %make WLcrop image
    end
end
end
