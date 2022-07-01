function [data]=readtiff(filename,varargin)

% Copyright 2022 Washington University in St. Louis
% 
%    Licensed under the Apache License, Version 2.0 (the "License");
%    you may not use this file except in compliance with the License.
%    You may obtain a copy of the License at
% 
%        http://www.apache.org/licenses/LICENSE-2.0
% 
%    Unless required by applicable law or agreed to in writing, software
%    distributed under the License is distributed on an "AS IS" BASIS,
%    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%    See the License for the specific language governing permissions and
%    limitations under the License.


try
info = imfinfo(filename);
catch
    disp(['Empty TIFF file for: ', filename, '....Moving on...'])
return
end

%Partial loading
numI = numel(info);
if numel(varargin)>0
    numI=varargin{1};
end



data=zeros(info(1).Width,info(1).Height,numI,'uint16');
fid=fopen(filename);
fseek(fid,info(1).Offset,'bof'); % the 8 is info(1).Offset
for k = 1:numI
    fseek(fid,[info(1,1).StripOffsets(1)-info(1,1).Offset],'cof');    % the 422 is info(1).StripOffset-info(1).Offset
    tempdata=fread(fid,info(1).Height*info(1).Width,'uint16');   
    data(:,:,k) = rot90((reshape(tempdata,info(1).Height,info(1).Width)),-1);
end
fclose(fid);

end

