function [mytform,fixed_cam1,registered_cam2] = getTransformation(firstFrame_cam1,firstFrame_cam2)
fixed_cam1 = firstFrame_cam1./max(max(firstFrame_cam1));
unregistered_cam2 = firstFrame_cam2./max(max(firstFrame_cam2));
f = msgbox(['click four pairs of points',newline,'export in movingPoints and fixedPoints',newline,'close after finish selection']);
pause(0.5)
[movingPoints,fixedPoints] = cpselect(unregistered_cam2,fixed_cam1,'Wait',true);
mytform = fitgeotrans(movingPoints, fixedPoints, 'projective');

registered_cam2 = imwarp(unregistered_cam2, mytform,'OutputView',imref2d(size(unregistered_cam2)));
C  = imfuse(registered_cam2,fixed_cam1,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
figure;
imagesc(C);
axis image off
title('projective')