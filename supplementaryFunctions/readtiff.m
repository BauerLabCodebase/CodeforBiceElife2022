function [data]=readtiff(filename,varargin)




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

