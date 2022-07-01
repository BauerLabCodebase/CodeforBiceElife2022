function [refseeds, I]=GetReferenceSeeds

%Get seed locations in reference mouse space. 

% (c) 2009 Washington University in St. Louis
% All Right Reserved
%
% Licensed under the Apache License, Version 2.0 (the "License");
% You may not use this file except in compliance with the License.
% A copy of the License is available is with the distribution and can also
% be found at:
%
% http://www.apache.org/licenses/LICENSE-2.0
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE, OR THAT THE USE OF THE SOFTWARD WILL NOT INFRINGE ANY PATENT
% COPYRIGHT, TRADEMARK, OR OTHER PROPRIETARY RIGHTS ARE DISCLAIMED. IN NO
% EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
% OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
% HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
% STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
% ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

[Seeds, L]=Seeds_PaxinosSpace;  % Normal 16 seed map

F=fieldnames(Seeds);
numf=numel(F);

OF(1)=64.5;             %Reference mouse Mid Anterior Suture x 
OF(2)=19;               %Reference mouse y 
T(1)=64.5;              %Reference mouse Lambda x 
T(2)=114;               %Reference mouse y 

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

refseeds=zeros(2*numf,2);

for f=1:numf;
    N=F{f};
    refseeds(f,1)=I.Seeds.R.(N)(1);
    refseeds(f,2)=I.Seeds.R.(N)(2);
    refseeds(numf+f,1)=I.Seeds.L.(N)(1);
    refseeds(numf+f,2)=I.Seeds.L.(N)(2);
end

end





