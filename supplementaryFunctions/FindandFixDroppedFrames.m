function fixed_by_channel=FindandFixDroppedFrames(data,runInfo)
%find dropped frame and interpolate
%if it is a dropped frame that is within the dark-frames period,
%Algortithm will not be able to find the frame because
%light levels are hardly changing. Instead, it will find the frame
%right befere the last last frame and insert a new frame (getting rid
%of the last frame in the sequence).

%iput data must be size pixel-pixel-time
%Output will be pixel-pixel-channel-time

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

%Initialize
OGsize=size(data);
numDropFrames=runInfo.totNum_frame-OGsize(3);


if numDropFrames==0 
fixed_by_channel=reshape(data,OGsize(1),OGsize(2),runInfo.numCh,[]);
else
    
    data=reshape(data,OGsize(1)*OGsize(2),[]);
    
    %Fix Dropped Frames During Dark Frames and a few points after
    DarkFrame_data=data(:,1:runInfo.numCh*runInfo.darkFramesInd(end)+2*runInfo.numCh); %all dark frames plus 2 frames per channel
    DarkFrame_data=reshape(DarkFrame_data,size(DarkFrame_data,1),runInfo.numCh,[]);
    mu_reshape=squeeze(mean(DarkFrame_data));
    ignore_frames=[1:2, runInfo.darkFramesInd(end):runInfo.darkFramesInd(end)+2]; %ignore 1st 2 frames and last 2 frames
    
    %Initialize jumps
    jumps=cell(1,runInfo.numCh);
    frames2Fix=cell(1,runInfo.numCh);
    
    %count how many dark frames were in darkFrame epoch
    darkFrame_dropped_num=0;

   
    for i=1:runInfo.numCh
        
        jumps(i)={ find(  sqrt((gradient(squeeze(mu_reshape(i,:))).^2)) >  .2*sqrt(mean(gradient(mu_reshape(i,3:end)).^2)))};
        frames2Fix(i)={setdiff(jumps{i},ignore_frames)} ;%Ignore the frames that are suppose to be there
        fixed_ch_data=squeeze(DarkFrame_data(:,i,:));
        
        for j=frames2Fix{i}
            darkFrame_dropped_num=darkFrame_dropped_num+1;
            fixed_ch_data(:,1:j-1)=fixed_ch_data(:,1:j-1); %dont change the beginning. Is this needed?
            fixed_ch_data(:,j:end)=[ fixed_ch_data(:,j-1) fixed_ch_data(:,j:end-1)]; %insert the frame that is a repeat of the last good frame and get rid of the last frame
            DarkFrame_data(:,i,:)=fixed_ch_data;
        end
        clear fixed_ch_data
    end
    clear mu_reshape
    
    %permute the order! THIS NEEDS WORK, but doesn't really
    %matter...
%     new_order    =[1:runInfo.numCh];
%     new_order=mod(new_order+runInfo.numCh-1*darkFrame_dropped_num,runInfo.numCh);
%     new_order(new_order==0)=runInfo.numCh;
    
    DarkFrame_data(:,:,end-1:end)=[]; %get rid of the 2 non-dark frames that I added in the beginning
    
    %Non-dark frames (so this will be numCh*numDarkFrames shorter than Original
    %size of data
    nonDark_droppedFrames=numDropFrames-darkFrame_dropped_num;
    NonDarkFrame_data=data(:,runInfo.numCh*runInfo.darkFramesInd(end)+1-darkFrame_dropped_num:end);
    mu=squeeze(mean(NonDarkFrame_data));
    %find where the dropped frames are
    tmp=histogram(gradient(mu),round(0.01*(runInfo.totNum_frame-runInfo.darkFramesInd(end)))); %consider about 1 percent bins
    tmp_ind=find(tmp.Values<=2 & tmp.Values>0); %find where these things happen once (or if they are super close, where they happen twice)
    
    drop_frame_loc=[];
    
    for i=1:numel(tmp_ind)
        drop_frame_loc= [drop_frame_loc find(gradient(mu) <= tmp.BinEdges(tmp_ind(i)+1) & gradient(mu)>= tmp.BinEdges(tmp_ind(i)))];
    end
    
    drop_frame_loc=sort(drop_frame_loc);
    
    drop_frame_loc(drop_frame_loc>=OGsize(3)-runInfo.darkFramesInd(end)*runInfo.numCh)=[]; %get rid of the last channel
    drop_frame_loc(drop_frame_loc <= 1*runInfo.numCh)=[]; %get rid of the first channel
    
    
    %fix them!
    for i=1:numel(drop_frame_loc)
        if i==1 %do this for the first one no matter what, but then if the two frames are next to eachother, then ignore and move on
            NonDarkFrame_data(:, drop_frame_loc(i)+1:end+1)= [ NonDarkFrame_data(:,drop_frame_loc(i)+runInfo.numCh)     NonDarkFrame_data(:, drop_frame_loc(i)+1 :end)]; %repeat the same frame
            drop_frame_loc=drop_frame_loc+1;      %shift for each frame that it corrects
        elseif i>1 && ( abs((drop_frame_loc(i-1)-drop_frame_loc(i))) >1)
            NonDarkFrame_data(:, drop_frame_loc(i)+1:end+1)= [ NonDarkFrame_data(:,drop_frame_loc(i)+runInfo.numCh)     NonDarkFrame_data(:, drop_frame_loc(i)+1 :end)]; %repeat the same frame
            drop_frame_loc=drop_frame_loc+1; %shift for each frame that it corrects
        end
    end
    
    
    %If there are still dropped frames then it is likely the first of last
    %frame, which we ignore, so just pad
    if size(NonDarkFrame_data,2)~=runInfo.totNum_frame-runInfo.darkFramesInd*runInfo.numCh%%xw original is size(NonDarkFrame_data,2)~=runInfo.totNum_frame
        NonDarkFrame_data(:, end+1)= NonDarkFrame_data(:,end-runInfo.numCh+1) ;
    end
    
    %Start fixing!
    fixed_by_channel=nan(OGsize(1)*OGsize(2),runInfo.totNum_frame);
    fixed_by_channel=reshape(fixed_by_channel,OGsize(1)*OGsize(2),runInfo.numCh,[]);
    fixed_by_channel(:,:,1:runInfo.darkFramesInd(end))=DarkFrame_data;
    fixed_by_channel(:,:,runInfo.darkFramesInd(end)+1:end)=reshape(NonDarkFrame_data,OGsize(1)*OGsize(2),runInfo.numCh,[]);
    fixed_by_channel=reshape(fixed_by_channel,OGsize(1),OGsize(2),runInfo.numCh,[]);
end
end