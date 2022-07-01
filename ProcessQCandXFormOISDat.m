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

%% Get Run and System Info

%Some user input!
excelFile="A:\JPC\DOI_RGeco\DOI_Database.xlsx";
excelRows=[11:60];


fRange_ISA = [0.01 0.08];
fRange_delta = [0.5 4];
runsInfo = parseRuns(excelFile,excelRows);
[row,start_ind_mouse,numruns_per_mouse]=unique({runsInfo.excelRow_char}); %Note that unique only takes characters! This makes it so that we only do landmark for one of the runs!
%% Get Masks and WL
previousDate = []; %initialize the date
mouse_ind=start_ind_mouse';
for runInd=mouse_ind %for each mouse

    runInfo=runsInfo(runInd);
    currentDate = runInfo.recDate;

    % For optogentics project, sometime the mask and landmarks will be made during acquisition, not processing
    if exist(runInfo.saveMaskFile,'file')
    variableInfo = who('-file', runInfo.saveMaskFile);
    else
        variableInfo = [];
    end

    if  ~contains(runInfo.system,'EastOIS2')

        if ~exist(runInfo.saveMaskFile,'file') || (~ismember('xform_StimROIMask', variableInfo) && runInfo.session =="stim") %%For laser case, we have a landmarksandMask without stimMask beofre the processing script
            raw = readtiff(runInfo.rawFile{1},300*runInfo.numCh);
            raw = reshape(raw,size(raw,1),size(raw,2),runInfo.numCh,[]); %reshape everything

            %getting ROI for stim
            if runInfo.session =="stim"
                tmp=nan(size(raw,1),size(raw,2),runInfo.numCh);
                fh = figure('units','normalized','outerposition',[0 0 1 1]);
                for jj=1:runInfo.numCh
                    tmp(:,:,jj)=(mean(raw(:,:,jj,runInfo.stimStartTime*runInfo.samplingRate+runInfo.darkFramesInd(end)+1:end),4)-...
                        mean(raw(:,:,jj,runInfo.darkFramesInd(end)+1:runInfo.darkFramesInd(end)+runInfo.stimStartTime*runInfo.samplingRate),4)).^2; %mean from dark frames to end
                    subplot(1,runInfo.numCh,jj)
                    imagesc(squeeze(tmp(:,:,jj)))
                    title(['CH:', num2str(jj)])
                    if jj==2
                            title(['PICK ME! CH:', num2str(jj)])
                    end
                    try
                    caxis(quantile(reshape(tmp(:,:,jj),1,[]),[0.001,.999]))
                    catch
                    caxis([min(reshape(tmp(:,:,jj),1,[])) max(reshape(tmp(:,:,jj),1,[]))] )                        
                    end                    
                    axis image
                    set(gca,'tag',num2str(jj))
                end
                sgtitle({'Click Subplot With Best Stim','Click Center'})
                StimROIMask=findStimROIMask(tmp,size(tmp,1),size(tmp,2));
                StimROIMask=imgaussfilt(double(StimROIMask),4); %smooth with 4 pixel kernel
                StimROIMask=StimROIMask>.5*max(max(StimROIMask));
                close
                imagesc(StimROIMask)
                pause(0.5)
                close
            end
            disp([runInfo.saveHbFile,' Label'])            
            [isbrain,xform_isbrain,I,WL,xform_WL] = getMask(raw,runInfo.darkFramesInd,runInfo.invalidFramesInd,runInfo.rgbInd);
            %Make a save folder
            if ~exist(runInfo.saveFolder)
                mkdir(runInfo.saveFolder);
            end

            if ~(runInfo.session=="stim")
                save(runInfo.saveMaskFile,'xform_WL','isbrain','I','xform_isbrain','WL','-v7.3');
            elseif ~exist(runInfo.saveMaskFile,'file') 
                xform_StimROIMask=affineTransform(StimROIMask,I);
                xform_StimROIMask=single(uint8(xform_StimROIMask));
                save(runInfo.saveMaskFile,'xform_WL','isbrain','I','xform_isbrain','WL','xform_StimROIMask','StimROIMask','-v7.3');
            else  %For optogentics project, sometime the mask and landmarks will be madeduring acquisition, not processing
                    save(runInfo.saveMaskFile,'xform_StimROIMask','StimROIMask','-append'); 
            end  
            close all
        end

    else 

        if ~exist(runInfo.saveMaskFile,'file') || (~ismember('xform_StimROIMask', variableInfo) && runInfo.session =="stim")%%xw 220603 for laser case, we have a landmarksandMask without stimMask beofre the processing script
            sessionInfo = sysInfo(runInfo.system);

            tmp=matfile(runInfo.rawFile{1});   %JPC partial load  -- has size size(test,'raw_unregistered')
            try
                raw_unregistered=tmp.raw_unregistered(:,:,1:200*runInfo.numCh); %JPC
            catch
                raw_unregistered=tmp.raw_unregistered(:,:,:,1:200); %JPC
            end
            raw_unregistered=reshape(raw_unregistered,size(raw_unregistered,1),size(raw_unregistered,2),runInfo.numCh,[]);

            %getting ROI for stim
            if runInfo.session =="stim"
                tmp=nan(size(raw_unregistered,1),size(raw_unregistered,2),runInfo.numCh);
                fh = figure('units','normalized','outerposition',[0 0 1 1]);
                for jj=1:runInfo.numCh
                    tmp(:,:,jj)=(mean(raw_unregistered(:,:,jj,runInfo.stimStartTime*runInfo.samplingRate+runInfo.darkFramesInd(end)+1:end),4)-...
                        mean(raw_unregistered(:,:,jj,runInfo.darkFramesInd(end)+1:runInfo.darkFramesInd(end)+runInfo.stimStartTime*runInfo.samplingRate),4)).^2; %mean from dark frames to end
                    subplot(1,runInfo.numCh,jj)
                    imagesc(squeeze(tmp(:,:,jj)))
                    title(['CH:', num2str(jj)])
                    if jj==2
                            title(['PICK ME! CH:', num2str(jj)])
                    end
                    try
                    caxis(quantile(reshape(tmp(:,:,jj),1,[]),[0.001,.999]))
                    catch
                    caxis([min(reshape(tmp(:,:,jj),1,[])) max(reshape(tmp(:,:,jj),1,[]))] )                        
                    end
                    axis image
                    set(gca,'tag',num2str(jj))
                end
                sgtitle({'Click Subplot With Best Stim','Click Center'})
                [StimROIMask, StimCh]=findStimROIMask(tmp,size(tmp,1),size(tmp,2));
                StimROIMask=imgaussfilt(double(StimROIMask),4); %smooth with 4 pixel kernel
                StimROIMask=StimROIMask>.5*max(max(StimROIMask));
                close
                imagesc(StimROIMask)
                pause(0.5)
                close
            end
            %%% NO longer checking if there is dark frame...Let's just
            %%% use the "second" frame!
            firstFrame_cam1  = squeeze(raw_unregistered(:,:,sessionInfo.rgb(2),runInfo.darkFramesInd(end)+1)); % First non dropped frame!

            clear raw_unregistered tmp
            tmp=matfile(runInfo.rawFile{2});   %JPC partial load  -- has size size(test,'raw_unregistered')
            try
                raw_unregistered=tmp.raw_unregistered(:,:,1:200*runInfo.numCh); %JPC
            catch
                raw_unregistered=tmp.raw_unregistered(:,:,:,1:200); %JPC
            end            
            raw_unregistered=reshape(raw_unregistered,size(raw_unregistered,1),size(raw_unregistered,2),runInfo.numCh,[]);

            firstFrame_cam2  = squeeze(raw_unregistered(:,:,sessionInfo.rgb(1),runInfo.darkFramesInd(end)+2)); % JPC made this +2 instead of +1

            clear raw_unregistered tmp

            if ~strcmp(previousDate,currentDate) && ~exist(fullfile(runInfo.saveFolder,strcat(runInfo.recDate,'-tform.mat')),'file')% xw 220601
                ind_recDate= strfind(runInfo.rawFile{1},runInfo.recDate);
                rawDataLoc = runInfo.rawFile{1}(1:ind_recDate(2)-1);
                if exist([rawDataLoc,runInfo.recDate,'-gridWL-cam1.mat'],'file') % use the paper grid to registration if there is one
                    load([rawDataLoc,runInfo.recDate,'-gridWL-cam1.mat'])
                    cam1 = mean(raw_unregistered(:,:,4,:),4);
                    cam1=normr(cam1);
                    clear raw_unregistered
                    load([rawDataLoc,runInfo.recDate,'-gridWL-cam2.mat'])
                    cam2 = mean(raw_unregistered(:,:,4,:),4);
                    cam2=normr(cam2); %JPC
                    clear raw_unregistered
                    [mytform,fixed_cam1,registered_cam2] = getTransformation(cam1,cam2);
                else
                    clear raw_unregistered
                    [mytform,fixed_cam1,registered_cam2] = getTransformation(firstFrame_cam1,firstFrame_cam2);%if no paper grid, use the mouse data.
                end
                if ~exist(runInfo.saveFolder)
                    mkdir(runInfo.saveFolder)
                end
                save(fullfile(runInfo.saveFolder,strcat(runInfo.recDate,'-tform.mat')),'mytform')
            end
            load(fullfile(runInfo.saveFolder,strcat(runInfo.recDate,'-tform.mat')),'mytform')
            previousDate = currentDate;
            fixed = firstFrame_cam1./max(max(firstFrame_cam1));
            unregistered = firstFrame_cam2./max(max(firstFrame_cam2));
            registered = imwarp(unregistered, mytform,'OutputView',imref2d(size(unregistered)));
            %%
            %Create White Light Image
            WL = zeros(128,128,3);
            WL(:,:,1) = registered;
            if (runInfo.session=="stim") %TO FIX ASAP: it is possible that the registered will have dropped frames. 
                if (StimCh~= 2) % if there is a dropped frame
                    WL(:,:,2) = 2.8*registered; %add some conrast!
                    WL(:,:,3) = 4*registered;   %add some conrast!             
                end
            else
            WL(:,:,2) = fixed;
            WL(:,:,3) = fixed;
            end
            disp([runInfo.saveHbFile,' Label'])
            [isbrain,xform_isbrain,I,seedcenter,WLcrop,xform_WLcrop,xform_WL] = getLandMarksandMask_Zyla(WL);
            %Make a save folder
            if ~exist(runInfo.saveFolder)
                mkdir(runInfo.saveFolder);
            end
            if ~(runInfo.session=="stim")
                save(runInfo.saveMaskFile,'xform_WL','isbrain','I','xform_isbrain','WL','-v7.3');
            else
                xform_StimROIMask=affineTransform(StimROIMask,I);
                xform_StimROIMask=single(uint8(xform_StimROIMask));
                save(runInfo.saveMaskFile,'xform_WL','isbrain','I','xform_isbrain','WL','xform_StimROIMask','StimROIMask','-v7.3');
            end
            close all

        end
    end
end



%% Process Data
% Process multiple OIS files with the following naming convention:

% filedate: YYMMDD
% subjname: any alphanumberic convention is ok, e.g. "Mouse1"
% suffix: filename run number, e.g. "fc1"
% In Andor Solis, files are saved as "YYMMDD-MouseName-suffixN.tif"

% "directory" is where processed data will be stored. If the
% folder does not exist, it is created, and if directory is not
% specified, data will be saved in the current folder:

runNum = numel(runsInfo);
for runInd = 1:runNum
    clearvars -except runsInfo runNum runInd fRange_ISA fRange_delta
    runInfo=runsInfo(runInd);

    %do these exist?
        stimExist=[runInfo.saveFilePrefix ,'-StimResults','.mat'];
        stimExist2=[strcat(runInfo.saveFilePrefix,'_GSR_BlockPeak_Dynamics.fig')];
        fcExist=[runInfo.saveFilePrefix '-seedFC-' num2str(fRange_ISA(1)) '-' num2str(fRange_ISA(2)) ];
        fcExist(strfind(fcExist,'.')) = 'p';
        fcExist=[fcExist '.mat'];
    %If is this already processed
    if exist( runInfo.saveHbFile,'file')  && ~( (exist(stimExist) && exist(stimExist2) && strcmp(runInfo.session,'stim') ) ||  (exist(fcExist) && strcmp(runInfo.session,'fc')) ) 
        disp([runInfo.saveHbFile,' Already pre-processed, Processing ' runInfo.session])
        load(runInfo.saveHbFile,'xform_datahb')
        load(runInfo.saveMaskFile,'xform_isbrain')

        if ~isempty(runInfo.fluorChInd)
            load(runInfo.saveFluorFile,'xform_datafluorCorr')
        end

        if ~isempty(runInfo.FADChInd)
            load(runInfo.saveFADFile,'xform_dataFADCorr')
        end

        if ~isempty(runInfo.laserChInd)    %xw 220603 add for laser channel
            load(strcat(runInfo.saveFilePrefix,'-dataLaser.mat'),'xform_datalaser')
        end

    elseif ((exist(stimExist) && exist(stimExist2) && strcmp(runInfo.session,'stim') ) ||  (exist(fcExist) && strcmp(runInfo.session,'fc') ))
        disp([runInfo.saveHbFile,' Already processed'])                
        continue
    else
        
        load(runInfo.saveMaskFile);

        disp(['Processing ', runInfo.saveHbFile ' on ', runInfo.system])
        sessionInfo = sysInfo(runInfo.system);

        %READ DATA AND FIND DROPPED FRAMES, and reshape
        if ~contains(runInfo.system,'EastOIS2')
            raw = readtiff(runInfo.rawFile{1});
            raw=FindandFixDroppedFrames(raw,runInfo); %JPC added
        else
            load(fullfile(runInfo.rawFile{1}))
            raw_unregistered = reshape(raw_unregistered,128,128,[]); %% Reshape because in the past we save raw_unregistered as 128*128*channels*frames            
            fixed_by_channel_cam1=FindandFixDroppedFrames(raw_unregistered,runInfo);
            binnedRaw_cam1 = fixed_by_channel_cam1(:,:,sessionInfo.cam1Chan,:);
            clear raw_unregistered fixed_by_channel_cam1

            load(fullfile(runInfo.rawFile{2}))
            fixed_by_channel_cam2=FindandFixDroppedFrames(raw_unregistered,runInfo);
            binnedRaw_cam2= fixed_by_channel_cam2(:,:,sessionInfo.cam2Chan,:);
            clear raw_unregistered fixed_by_channel_cam2

            load(fullfile(runInfo.saveFolder,strcat(runInfo.recDate,'-tform.mat')),'mytform')
            raw  = registerCam2andCombineTwoCams(binnedRaw_cam1,binnedRaw_cam2,mytform,sessionInfo.cam1Chan,sessionInfo.cam2Chan);
            save(fullfile(runInfo.saveFolder,strcat(runInfo.recDate,'-',runInfo.mouseName,'-',runInfo.session,num2str(runInfo.run))),'raw','-v7.3')
        end

        %DARK FRAME REMOVAL
        % Remove dark  frames (JPC changed to subtract average across all
        % darkframes
        if ~isempty(runInfo.darkFramesInd)
            runInfo.darkFramesInd(runInfo.darkFramesInd == runInfo.invalidFramesInd) = [];
            darkFrame = squeeze(mean(reshape(raw(:,:,:,runInfo.darkFramesInd),size(raw,1),size(raw,2),[]),3,'omitnan')); %JPC made it so that we took average across all 4 "channels"

            %Eliminate dark frames from
            if contains(runInfo.system,'EastOIS2')
                raw(:,:,sessionInfo.cam2Chan,:) = double(raw(:,:,sessionInfo.cam2Chan,:)) - double(repmat(darkFrame,1,1,numel(sessionInfo.cam2Chan),size(raw(:,:,sessionInfo.cam2Chan,:),4)));
                raw(:,:,sessionInfo.cam1Chan,:) = double(raw(:,:,sessionInfo.cam1Chan,:)) - double(repmat(darkFrame,1,1,numel(sessionInfo.cam1Chan),size(raw(:,:,sessionInfo.cam1Chan,:),4)));
            else
                raw = double(raw) - double(repmat(darkFrame,1,1,size(raw,3),size(raw,4)));
            end

            %             raw(:,:,:,1:runInfo.darkFramesInd(end)+1)=[]; %JPC get rid of the dark frames,
            raw(:,:,:,end)=raw(:,:,:,end-1); %JPC get rid of last frame too and make it the same as the one before it
            raw(:,:,:,1:runInfo.darkFramesInd(end))=[]; %JPC get rid of the dark frames

        else
            raw(:,:,:,runInfo.invalidFramesInd) = [];%invalidFramesInd default is 1
        end
        clear darkFrame

        % QC RAW DATA
        disp('rawQC analysis...');
        if ~isempty(runInfo.fluorChInd)
            representativeCh = runInfo.fluorChInd;
        else
            %which channel are we using as a reference
            representativeCh = runInfo.hbChInd(1);
        end

        rawTime = 1:size(raw,4);
        rawTime = rawTime/runInfo.samplingRate;
        load(runInfo.saveMaskFile)
        raw = single(raw);
        qcRawFig = qcRaw(runInfo,rawTime,raw,representativeCh,isbrain,runInfo.system);
        savefig(qcRawFig,runInfo.saveRawQCFig);
        saveas(qcRawFig,[runInfo.saveRawQCFig '.png']);
        close(qcRawFig);

        %Detrending
        for i=1: size(raw,3)
            raw(:,:,i,:)=temporalDetrend(squeeze(raw(:,:,i,:)),isbrain);
        end
        %OPTICAL PROP AND SPECTROSCOPY
        %HB
        [op, E] = getHbOpticalProperties({runInfo.lightSourceFiles{runInfo.hbChInd}});
        datahb = procOIS(raw(:,:,runInfo.hbChInd,:),op.dpf,E,isbrain); %where is xform_isbrain made?
        datahb = smoothImage(datahb,runInfo.gbox,runInfo.gsigma);
        xform_datahb = affineTransform(datahb,I); %error here
        xform_isbrain_matrix = repmat(xform_isbrain,1,1,size(xform_datahb,3),size(xform_datahb,4));
        xform_datahb(logical(1-xform_isbrain_matrix)) = NaN;
        save(runInfo.saveHbFile,'xform_datahb','op','E','runInfo','-v7.3')


        %Fluoro (calcium)
        if ~isempty(runInfo.fluorChInd)
            [op_in, E_in] = getHbOpticalProperties({runInfo.lightSourceFiles{runInfo.fluorChInd}});
            [op_out, E_out] = getHbOpticalProperties(runInfo.fluorFiles);
            dpIn = op_in.dpf/2;
            dpOut = op_out.dpf/2;

            datafluor = procFluor(squeeze(raw(:,:,runInfo.fluorChInd,:)),mean(raw(:,:,runInfo.fluorChInd,:),4,'omitnan'));
            datafluor = smoothImage(datafluor,runInfo.gbox,runInfo.gsigma);
            xform_datafluor = affineTransform(datafluor,I);
            %Fluoro-Correction
            if  strcmp('EastOIS1_GCaMP',runInfo.system) %gcamp correction
                datafluorCorr = correctHb_differentBeta(datafluor,datahb,[E_in(1) E_out(1)],[E_in(2) E_out(2)],dpIn,dpOut,0.7,0.8);
            elseif contains(runInfo.system,'EastOIS2') %jRGECGO1a correction
                datafluorCorr = correctHb_differentBeta(datafluor,datahb,[E_in(1) E_out(1)],[E_in(2) E_out(2)],dpIn,dpOut,1,1);
            end
            datafluorCorr = smoothImage(datafluorCorr,runInfo.gbox,runInfo.gsigma);
            xform_datafluorCorr=affineTransform(datafluorCorr,I);
            save(runInfo.saveFluorFile,'xform_datafluor','xform_datafluorCorr','op_in', 'E_in', 'op_out', 'E_out','runInfo','-v7.3')
            clear datafluor datafluorCorr xform_datafluor
        end


        %FAD
        if ~isempty(runInfo.FADChInd)
            [op_inFAD, E_inFAD] = getHbOpticalProperties({runInfo.lightSourceFiles{runInfo.FADChInd}});
            [op_outFAD, E_outFAD] = getHbOpticalProperties(runInfo.FADFiles);
            dpIn = op_inFAD.dpf/2;
            dpOut = op_outFAD.dpf/2;

            dataFAD = procFluor(squeeze(raw(:,:,runInfo.FADChInd,:)),mean(raw(:,:,runInfo.FADChInd,:),4,'omitnan'));
            dataFAD = smoothImage(dataFAD,runInfo.gbox,runInfo.gsigma);
            xform_dataFAD = affineTransform(dataFAD,I);
            clear raw
            %FAD-Correction
            dataFADCorr = correctHb_differentBeta(dataFAD,datahb,[E_inFAD(1) E_outFAD(1)],[E_inFAD(2) E_outFAD(2)],dpIn,dpOut,1,1);
            dataFADCorr = smoothImage(dataFADCorr,runInfo.gbox,runInfo.gsigma);
            xform_dataFADCorr=affineTransform(dataFADCorr,I);


            save(runInfo.saveFADFile,'xform_dataFAD','xform_dataFADCorr','op_inFAD', 'E_inFAD', 'op_outFAD', 'E_outFAD','runInfo','-v7.3')
            clear dataFAD xform_dataFAD dataFADCorr
        end

        clear datahb rawTime  isbrain

        %Laser Frame
        if ~isempty(sessionInfo.chLaser)
            datalaser =  squeeze(raw(:,:,sessionInfo.chLaser,:));
            xform_datalaser = affineTransform(datalaser,I);
            xform_isbrain_matrix = repmat(xform_isbrain,1,1,size(xform_datalaser,3));
            xform_datalaser(logical(1-xform_isbrain_matrix)) = NaN;
            save(strcat(runInfo.saveFilePrefix,'-dataLaser.mat'),'xform_datalaser','runInfo','-v7.3')
        end
    end

    %Pre-FC Process:
    OGsize=size(xform_datahb);
    if runInfo.session =="fc"

            %Initialize
            if ~isempty(runInfo.fluorChInd)
                data_full = nan(size(xform_datahb,1),size(xform_datahb,2),size(xform_datahb,4),4);
            elseif ~isempty(runInfo.FADChInd)
                data_full = nan(size(xform_datahb,1),size(xform_datahb,2),size(xform_datahb,4),5);
            else
                data_full = nan(size(xform_datahb,1),size(xform_datahb,2),size(xform_datahb,4),3);
            end
            %Shape Data
            data_full(:,:,:,1)=squeeze(xform_datahb(:,:,1,:));
            data_full(:,:,:,2)=squeeze(xform_datahb(:,:,2,:));
            data_full(:,:,:,3)=squeeze(xform_datahb(:,:,1,:))+squeeze(xform_datahb(:,:,2,:));
            if ~isempty(runInfo.fluorChInd)
                data_full(:,:,:,4) = xform_datafluorCorr;
            end
            if ~isempty(runInfo.FADChInd)
                data_full(:,:,:,5) = xform_dataFADCorr;
            end

%Power Break
            %initialize
            hz_size= 2^floor(log2(size(data_full,3)))/4+1;
            whole_spectra_map=nan(128,128,hz_size,numel(runInfo.Contrasts));
            avg_cort_spec=nan(hz_size,numel(runInfo.Contrasts));
            powerMap=nan(128,128,3,numel(runInfo.Contrasts));
            global_sig_for=nan(hz_size,numel(runInfo.Contrasts));
            glob_sig_power=nan(3,numel(runInfo.Contrasts));

            for contrast=1:numel(runInfo.Contrasts)
                  [whole_spectra_map(:,:,:,contrast),avg_cort_spec(:,contrast),powerMap(:,:,:,contrast),hz, global_sig_for(:,contrast),glob_sig_power(:,contrast)]= PowerAnalysis(squeeze(data_full(:,:,:,contrast)),runInfo.samplingRate,xform_isbrain,fft_bool); 
            end
            save(strcat(runInfo.saveFilePrefix,'-Power.mat'),'hz','whole_spectra_map','powerMap','global_sig_for','glob_sig_power','avg_cort_spec','-v7.3')

            clear  xform_datafluorCorr xform_datahb xform_dataFADCorr ...
                whole_spectra_map powerMap global_sig_for glob_sig_power avg_cort_spec

            %Filter and downsample
            data_isa_tmp= nan(size(data_full));
            data_delta_tmp= nan(size(data_full));
            data_isa=   nan(size(data_full,1),size(data_full,2),size(data_full,3)*((2*fRange_ISA(2)*1.25)/runInfo.samplingRate) ,size(data_full,4));
            data_delta= nan(size(data_full,1),size(data_full,2),size(data_full,3)*((2*fRange_delta(2)*1.25)/runInfo.samplingRate) ,size(data_full,4));
            for ii=1:size(data_full,4)
                data_isa_tmp(:,:,:,ii)=filterData(data_full(:,:,:,ii),fRange_ISA(1),fRange_ISA(2),runInfo.samplingRate,xform_isbrain);
                data_isa(:,:,:,ii)=resample(squeeze(data_isa_tmp(:,:,:,ii)), (2*fRange_ISA(2)*1.25) ,runInfo.samplingRate,'Dimension',3);

                data_delta_tmp(:,:,:,ii)=filterData(data_full(:,:,:,ii),fRange_delta(1),fRange_delta(2),runInfo.samplingRate,xform_isbrain);
                data_delta(:,:,:,ii)=resample(squeeze(data_delta_tmp(:,:,:,ii)), (2*fRange_delta(2)*1.25) ,runInfo.samplingRate,'Dimension',3);
            end

            clear data_full data_delta_tmp data_isa_tmp

            %GSR
            for  ii=1:size(data_isa,4)
                data_isa(:,:,:,ii) = gsr(squeeze(data_isa(:,:,:,ii)),xform_isbrain);
                data_delta(:,:,:,ii) = gsr(squeeze(data_delta(:,:,:,ii)),xform_isbrain);
            end
            xform_isbrain_matrix = repmat(xform_isbrain,1,1,size(data_isa,3),size(data_isa,4));
            data_isa(logical(1-xform_isbrain_matrix)) = NaN;%
            xform_isbrain_matrix = repmat(xform_isbrain,1,1,size(data_delta,3),size(data_delta,4));
            data_delta(logical(1-xform_isbrain_matrix)) = NaN;

            clear xform_isbrain_matrix

            %QC FC
            %ISA
            tic
            fStr = [num2str(fRange_ISA(1)) '-' num2str(fRange_ISA(2))];
            fStr(strfind(fStr,'.')) = 'p';
            ContFig2Save= {'HbO','HbT'};
            [fh, seedFC, seedFCMap,seedCenter,seedRadius,bilatFCMap]...
                = qcFC(data_isa,xform_isbrain,runInfo.Contrasts,runInfo,fRange_ISA,ContFig2Save);
            for contrastInd = 1:numel(ContFig2Save)
                saveFCQCFigName = [runInfo.saveFCQCFig '-' ContFig2Save{contrastInd} '-' fStr ];
                saveas(fh(contrastInd),[saveFCQCFigName '.png']);
                close(fh(contrastInd));
            end
            toc
            %Saving
            contrastName = runInfo.Contrasts;
            saveSeedFCName = [runInfo.saveFilePrefix '-seedFC-' fStr];
            save(saveSeedFCName,'contrastName','seedCenter','seedFC','seedFCMap','seedRadius','-v7.3');
            saveBilateralFCName = [runInfo.saveFilePrefix '-bilateralFC-' fStr];
            save(saveBilateralFCName,'contrastName','bilatFCMap','xform_isbrain','-v7.3');

            %Delta Band
            if ~isempty(runInfo.fluorChInd)
                fStr = [num2str(fRange_delta(1)) '-' num2str(fRange_delta(2))];
                fStr(strfind(fStr,'.')) = 'p';
                ContFig2Save= {'Calcium'};
                if ~isempty(runInfo.FADChInd)
                    ContFig2Save= {'Calcium','FAD'};
                end
                clear fh
                [fh, seedFC, seedFCMap,seedCenter,seedRadius,bilatFCMap]...
                    = qcFC(data_delta,xform_isbrain,runInfo.Contrasts,runInfo,fRange_delta,ContFig2Save);
                for contrastInd = 1:numel(ContFig2Save)
                    saveFCQCFigName = [runInfo.saveFCQCFig '-' ContFig2Save{contrastInd} '-' fStr ];
                    saveas(fh(contrastInd),[saveFCQCFigName '.png']);
                    close(fh(contrastInd));
                end

                %Saving
                saveSeedFCName = [runInfo.saveFilePrefix '-seedFC-' fStr];
                save(saveSeedFCName,'contrastName','seedCenter','seedFC','seedFCMap','seedRadius','-v7.3');
                saveBilateralFCName = [runInfo.saveFilePrefix '-bilateralFC-' fStr];
                save(saveBilateralFCName,'contrastName','bilatFCMap','xform_isbrain','-v7.3');
            end

    elseif runInfo.session =="stim"

            load(runInfo.saveMaskFile,'xform_isbrain')
            mask=find(xform_isbrain);
            %Building Data Full
            if ~isempty(runInfo.fluorChInd)
                data_full = nan(size(xform_datahb,1),size(xform_datahb,2),size(xform_datahb,4),4);
            elseif ~isempty(runInfo.FADChInd)
                data_full = nan(size(xform_datahb,1),size(xform_datahb,2),size(xform_datahb,4),5);
            else
                data_full = nan(size(xform_datahb,1),size(xform_datahb,2),size(xform_datahb,4),3);
            end
            %Shape Data
            data_full(:,:,:,1)=squeeze(xform_datahb(:,:,1,:))*10^6;
            data_full(:,:,:,2)=squeeze(xform_datahb(:,:,2,:))*10^6;
            data_full(:,:,:,3)=squeeze(xform_datahb(:,:,1,:))*10^6+squeeze(xform_datahb(:,:,2,:))*10^6;
            if ~isempty(runInfo.fluorChInd)
                data_full(:,:,:,4) = xform_datafluorCorr*100;
            end
            if ~isempty(runInfo.FADChInd)
                data_full(:,:,:,5) = xform_dataFADCorr*100;
            end

            clear xform_datafluorCorr xform_dataFADCorr xform_datahb

            %Power Break- Can we initalize it?
            hz_size=2049; %seems to be the default...Need to find a data driven way. This is for pwelch
            whole_spectra_map=nan(128,128,hz_size,numel(runInfo.Contrasts));
            avg_cort_spec=nan(hz_size,numel(runInfo.Contrasts));
            powerMap=nan(128,128,3,numel(runInfo.Contrasts));
            global_sig_for=nan(hz_size,numel(runInfo.Contrasts));
            glob_sig_power=nan(3,numel(runInfo.Contrasts));

            for contrast=1:numel(runInfo.Contrasts)
                  [whole_spectra_map(:,:,:,contrast),avg_cort_spec(:,contrast),powerMap(:,:,:,contrast),hz, global_sig_for(:,contrast),glob_sig_power(:,contrast)]= PowerAnalysis(squeeze(data_full(:,:,:,contrast)),runInfo.samplingRate,xform_isbrain,fft_bool); 
            end
            save(strcat(runInfo.saveFilePrefix,'-Power.mat'),'hz','whole_spectra_map','powerMap','global_sig_for','glob_sig_power','-v7.3')

            clear whole_spectra_map powerMap global_sig_for glob_sig_power

            %Time Ranges: This is for anesthetized
            %do we need this...? Cant we just call runsInfo? -- JPC
            peakTimeRange(1:size(data_full,4))={runInfo.stimStartTime:runInfo.stimEndTime};
            %Setting up stim
            stimBlockSize=round(runInfo.blockLen*runInfo.samplingRate); %stim length in frames
            %why is this here?
            R=mod(size(data_full,3),stimBlockSize); %are there dropped frames?
            %if there is dropped frames
            if R~=0
                pad=stimBlockSize-R;
                disp(['** Non integer number of blocks presented. Padded with ' , num2str(pad), ' zeros **'])
                data_full(:,:,end:end+pad,:)=0;
                runInfo.appendedZeros=pad;
            end
            numBlocks = round(size(data_full,3)/(runInfo.blockLen*runInfo.samplingRate));%what if not integer

            % GSR, Filter, Downsample
            data_full = reshape(data_full,size(data_full,1),size(data_full,2),[],length(runInfo.Contrasts));
            for ii = 1:length(runInfo.Contrasts)
                data_full(:,:,:,ii) =  filterData(squeeze(squeeze(data_full(:,:,:,ii))),0.01,5,runInfo.samplingRate);                   
            end
            data_full_BaselineShift= resample(data_full,(2*fRange_delta(2)*1.25),runInfo.samplingRate,'Dimension',3 ); %resample to 10 Hz
            data_full_gsr_BaselineShift=nan(size(data_full_BaselineShift));
            for ii = 1:length(runInfo.Contrasts)
                data_full_gsr_BaselineShift(:,:,:,ii) = gsr(squeeze(data_full_BaselineShift(:,:,:,ii)),xform_isbrain);
            end

            runInfo.samplingRate=(2*fRange_delta(2)*1.25); %change the sampling rate to fit the resample frequency
            clear data_full_gsr data_full

            %Reshape into blocks
            data_full_gsr_BaselineShift = reshape(data_full_gsr_BaselineShift,size(data_full_gsr_BaselineShift,1),size(data_full_gsr_BaselineShift,2),[],numBlocks,size(data_full_gsr_BaselineShift,4)); %reshape to pixel-pixel-blockSize-numblock-species
            data_full_BaselineShift = reshape(data_full_BaselineShift,size(data_full_BaselineShift,1),size(data_full_BaselineShift,2),[],numBlocks,size(data_full_BaselineShift,4)); %reshape to pixel-pixel-blockSize-numblock-species

            %Mean subtraction
            meanFrame = squeeze(mean(data_full_BaselineShift(:,:,1:runInfo.stimStartTime*runInfo.samplingRate,:,:),3));
            data_full_BaselineShift = xform_isbrain.*(data_full_BaselineShift - permute(repmat(meanFrame,1,1,1,1, size(data_full_BaselineShift,3)), [1,2,5,3,4]  ));

            meanFrame = squeeze(mean(data_full_gsr_BaselineShift(:,:,1:runInfo.stimStartTime*runInfo.samplingRate,:,:),3));
            data_full_gsr_BaselineShift = xform_isbrain.*(data_full_gsr_BaselineShift - permute(repmat(meanFrame,1,1,1,1, size(data_full_gsr_BaselineShift,3)), [1,2,5,3,4]  ));
            clear  meanFrame

            %Create Peak maps
            load(runInfo.saveMaskFile,'xform_StimROIMask');

            [fh,peakMaps]= generateBlockMap_Dynamics(data_full_BaselineShift,data_full_gsr_BaselineShift,runInfo,numBlocks,peakTimeRange,xform_isbrain,xform_StimROIMask);
            %save
            sgtitle([runInfo.recDate '-' runInfo.mouseName '-' num2str(runInfo.run),'-GSR'])
            saveName = strcat(runInfo.saveFilePrefix,'_GSR_BlockPeak_Dynamics');
            saveas(gcf,strcat(saveName,'.fig'))
            export_fig(strcat(saveName,'.png'), '-transparent') 
            close all
            save([runInfo.saveFilePrefix '-StimResults'],'data_full_gsr_BaselineShift','data_full_BaselineShift','-v7.3');

    end
    disp(['Done Processing ', runInfo.saveHbFile ' on ', runInfo.system])

end




