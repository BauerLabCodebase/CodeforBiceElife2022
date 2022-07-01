function raw  = registerCam2andCombineTwoCams(rawdata_cam1,rawdata_cam2,mytform,cam1Chan,cam2Chan)

registered_cam2 = zeros(size(rawdata_cam2));

channels_cam2 = size(rawdata_cam2,3);
for ii = 1: channels_cam2
    for jj = 1:size(rawdata_cam2,4)
        registered_cam2(:,:,ii,jj) = imwarp(rawdata_cam2(:,:,ii,jj), mytform,'OutputView',imref2d(size(rawdata_cam2)));
    end
end

channels = size(rawdata_cam1,3)+size(rawdata_cam2,3);
raw = zeros(size(rawdata_cam1,1),size(rawdata_cam1,2),channels,size(rawdata_cam1,4));
raw(:,:,cam1Chan,:) = rawdata_cam1;
raw(:,:,cam2Chan,:) = registered_cam2;
