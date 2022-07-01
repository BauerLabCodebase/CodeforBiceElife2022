function T2 = affineMarker2affine2d(spatialSize,affineMarkers)
%affineMarker2affine2d Create affine2d object
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

RMAS(1)=(64.5/128)*spatialSize(1);         %Reference mouse Mid Anterior Suture x
RMAS(2)=(19/128)*spatialSize(1);           %Reference mouse y
RLam(1)=(64.5/128)*spatialSize(1);         %Reference mouse Lambda x
RLam(2)=(114/128)*spatialSize(1);          %Reference mouse y
RB(1)=mean([RMAS(1) RLam(1)]); %bisecting x
RB(2)=mean([RMAS(2) RLam(2)]); %bisecting y
R3(1)=RB(1)+RB(2)/2;    %Third point x, center point plus half dist between suture and lambda
R3(2)=RB(2);            %Third point y,  same y coord as biscenting point

%% Input Mouse Coordinates
MLam=affineMarkers.tent;        %original clicked lambda
MLam = MLam.*spatialSize;
MMAS=affineMarkers.OF;          %original clicked anterior suture
MMAS = MMAS.*spatialSize;

MB(1)=mean([MMAS(1) MLam(1)]); %bisecting x
MB(2)=mean([MMAS(2) MLam(2)]); %bisecting y

Mang=atan2(MLam(1)-MB(1),(MLam(2)-MB(2))); %angle of bisector with respect to y axis

M3(1)=MB(1)+MB(2)/2*cos(-Mang);  %coordinates of third point, half the distance between midpoint and lambda (or anterior suture)
M3(2)=MB(2)+MB(2)/2*sin(-Mang);

%% Use coordinates to generate affine transform matrix
Refpoints=[RMAS 1; R3 1; RLam 1];
Mousepoints=[MMAS 1; M3 1; MLam 1];

W=Mousepoints\Refpoints;% transform matrix

%% Generate Affine transform struct and transform
% Xdata and Ydata specify output grid...
% using this centers the output image at the transformed midpoint
% now all output images will share a common anatomical center

T = maketform('affine',W);
T2 = affine2d(W);

end
