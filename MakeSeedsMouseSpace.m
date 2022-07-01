function [I, seedcenter]=MakeSeedsMouseSpace(WL)

% This function calculates the locations of the predefinded seeds in atlas
% space and maps them to mouse space. "seedcenter" contains the locations
% of the seeds in mouse space, and I contains the landmark locations

%% GetLandmarks for mouse
WLfig=figure;

image(WL)
axis image;

nVx=size(WL,1);
nVy=nVx;

disp('Click Anterior Midline Suture Landmark');
[x y]=ginput(1);
x=round(x);
y=round(y);

OF(1)=x;
OF(2)=y;

disp('Click Lambda');
[x y]=ginput(1);
x=round(x);
y=round(y);

T(1)=x;
T(2)=y;

%% Get Seeds according to Atlas Space 
[Seeds, L]=Seeds_PaxinosSpace;  % Normal 16 seed map

F=fieldnames(Seeds);
numf=numel(F);


%% Transform atlas seeds to mouse space
adist=norm(L.of-L.tent);    %Paxinos Space
idist=norm(OF-T);           %Mouse Space

aa=atan2(L.of(1)-L.tent(1),L.of(2)-L.tent(2));  %Angle in Paxinos Space
ia=atan2(OF(1)-T(1),OF(2)-T(2));                %Angle in Mouse Space
da=ia-aa;                           %Mouse-Paxinos

pixmm=idist/adist;                  %Mouse/Pax
R=[cos(da) -sin(da) ; sin(da) cos(da)];

I.bregma=pixmm*(L.bregma*R);
I.tent=pixmm*(L.tent*R);
I.OF=pixmm*(L.of*R);

t=T-I.tent;             %translation=mouse-Paxinos

I.bregma=I.bregma+t;
I.tent=I.tent+t;
I.OF=I.OF+t;

F=fieldnames(Seeds.R);
numf=numel(F);

for f=1:numf
    N=F{f};
    I.Seeds.R.(N)=round(pixmm*Seeds.R.(N)*R+I.bregma);
    I.Seeds.L.(N)=round(pixmm*Seeds.L.(N)*R+I.bregma);
end

seedcenter=zeros(2*numf,2);

for f=0:numf-1;
    N=F{f+1};
    seedcenter(2*(f+1)-1,1)=I.Seeds.R.(N)(1);
    seedcenter(2*(f+1)-1,2)=I.Seeds.R.(N)(2);
    seedcenter(2*(f+1),1)=I.Seeds.L.(N)(1);
    seedcenter(2*(f+1),2)=I.Seeds.L.(N)(2);
  
end

%% Visualize landmarks and seeds

if max(WL(:))>1
    WL=double(WL)/255;
else
    WL=WL;
end

close(WLfig)

figure
imagesc(WL); %changed 3/1/1
axis off
axis image
title('White Light Image');

  
for f=1:size(seedcenter,1)
    hold on;
    plot(seedcenter(f,1),seedcenter(f,2),'ko','MarkerFaceColor','k')
end

    hold on;
    plot(I.tent(1,1),I.tent(1,2),'ko','MarkerFaceColor','b')
    hold on;
    plot(I.bregma(1,1),I.bregma(1,2),'ko','MarkerFaceColor','b')
    hold on;
    plot(I.OF(1,1),I.OF(1,2),'ko','MarkerFaceColor','b')


end





