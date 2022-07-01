function runsInfo = parseRuns(excelFile,excelRows)
%parseTiffRuns Parses information from excel sheet about tiff runs and
%outputs information about each run
%
% Some of the information about run can be changed by user input via excel
% file. Here are some of them listed:
%
%   Raw Data Location (required) = location of raw data
%
%   Date (required) = date of recording. Used to find the subfolder
%   containing raw data within Raw Data Location.
%
%   Save Location (required) = location of processed data
%
%   Mouse (required) = mouse name. Used to name files
%
%   Session (required) = type of session. fc or stim? This determines
%   quality control functions to be run. It also affects the names of saved
%   files.
%
%   System (required) = which system is used? This is the input toa
%   mouse.expSpecific.sysInfo that outputs various information about the
%   system including LEDs used, fluorophore, valid thresholds for light
%   intensity, number of invalid frames, smoothing parameters, spatial
%   binning factors, channels used for hemoglobin or other
%   calculations. Ex) 'EastOIS1'
%
%   Sampling Rate (required) = frequency of each channel recorded in Hz.
%   Ex) 20
%
%   Good Runs (optional) = states the good runs, and only these are run.
%   Default = all runs. Ex) 1,2,4 if runs 1, 2 and 4 should be run.
%
%   Num Ch (optional) = number of channels. Default = output from
%   mouse.expSpecific.sysInfo. Ex) 4
%
%   Hb Ch Ind (optional) = indices of channels to be used for hemoglobin
%   calculation. Default = output from mouse.expSpecific.sysInfo. Ex) 1,3
%
%   Fluor Ch Ind (optional) = indices of channels to be used for
%   fluorescence calculation. Default = output from mouse.expSpecific.sysInfo. Ex) 1,3
%
%   Speckle Ch Ind (optional) = indices of channels to be used for speckle
%   calculation. Default = output from mouse.expSpecific.sysInfo. Ex) 1,3
%
%   RGB Ind (optional) = indices of channels pertaining to red, green, and
%   blue in that order. Default = output from mouse.expSpecific.sysInfo.
%   Ex) 1,3,4
%
%   G Box (optional) = the size of box in pixels containing gaussian
%   wavelet to be convolved over image for smoothing. Default = 5. Ex) 3
%
%   G Sigma (optional) = the full width half max in pixels of gaussian
%   wavelet to be convolved over image for smoothing. Default = 1.2. Ex) 2
%
%   Valid Threshold (optional) = the two numbers determining the minimum
%   and maximum light intensity values at which the data would be valid.
%   Default = output from mouse.expSpecific.sysInfo. Ex) 1,16382
%
%   Num Dark Frames (optional) = number of dark frames (per channel) at the beginning of
%   imaging session. Default = 0. Ex) 5
%
%   Num Invalid Frames (optional) = number of invalid frames (per channel)
%   at the beginning of imaging session. Default = output from
%   mouse.expSpecific.sysInfo. Ex) 5
%
%   Detrend Hb (optional) = whether to detrend hemoglobin. Either 0 or 1.
%   Default = 1 (true). Ex) 0
%
%   Detrend Fluor (optional) = whether to detrend fluorescence. Either 0 or
%   1. Default = 1 (true). Ex) 0
%
%   Save Raw (optional) = whether to save raw data. Either 0 or 1. Default
%   = 0 (false). Ex) 1
%
%   Save Mask File (optional) = directory of file to write landmarks and
%   mask to. Default = save location/date/date-mouse-LandmarksAndMask.mat
%
%   Save Raw File (optional) = directory of file to write raw data to.
%   Default = save location/date/date-mouse-systemRun-dataRaw.mat Ex)
%   C:/raw.mat
%
%   Save Hb File (optional) = directory of file to write hb data to.
%   Default = save location/date/date-mouse-systemRun-dataHb.mat Ex)
%   C:/hb.mat
%
%   Save Fluor File (optional) = directory of file to write fluor data to.
%   Default = save location/date/date-mouse-systemRun-dataFluor.mat Ex)
%   C:/fluor.mat
%
%   Save Cbf File (optional) = directory of file to write hb data to.
%   Default = save location/date/date-mouse-systemRun-dataCbf.mat Ex)
%   C:/cbf.mat
%
%   QC (optional) = whether to conduct quality control on processed data.
%   Default = 1 (true). Ex) 0
%
%   Sampling Rate Hb (optional) = output frequency of hemoglobin. Default =
%   2 Hz. Ex) 5
%
%   Sampling Rate Fluor (optional) = output frequency of fluorescence.
%   Default = raw data's sampling rate. Ex) 5
%
%   Sampling Rate Cbf (optional) = output frequency of cerebral blood flow.
%   Default = raw data's sampling rate. Ex) 5
%
%   Stim Roi Seed (optional) = the region that should be looked at first to
%   find the correct seed for stimulation response. Normalized to size of
%   the image. First number is y, then second number is x. For example,
%   0.3,0.5 means 30% from top, 50% from left. Should be two numbers
%   separated by a comma. Default = 0.4922,0.2344. Ex) 0.6,0.25
%
%   Stim Start Time (optional) = stimulation start time in seconds. Default
%   = 5. Ex) 10
%
%   Stim End Time (optional) = stimulation end time in seconds. Default =
%   10. Ex) 20
%
%   Block Len (optional) = length of each stimulation block in seconds.
%   Default = 60. Ex) 30
%
%   Bin Factor (optional) = how much each channel data should be binned
%   spatially. Default = output from mouse.expSpecific.sysInfo. Ex) 4,4,4,1
%   (if there are 4 channels and the first 3 channels should be binned by
%   factor of 4).
%
%   Affine Transform (optional) = whether to do affine transformation on
%   processed data. Default = 1 (true). Ex) 0
%
%   Window (optional) = image view dimensions in mm. First number is y
%   coordinate of bottom of image. Second number is vertical height of
%   image. Third number is x coordinate of left of image. Fourth number is
%   horizontal width of image. Default = -5,5,-5,5. Ex) 0,10,-5,20

runsInfo = [];

excelData = readtable(excelFile);
tableRows = excelRows - 1;

totalRunInd = 0;
for row = tableRows % for each row of excel file
    % required info for each excel row
    rawDataLoc = excelData{row,'RawDataLocation'}; rawDataLoc = rawDataLoc{1};
    recDate = excelData{row,'Date'};
    if iscell(recDate)
        recDate = recDate{1};
    else
        recDate = num2str(recDate);
    end
    saveLoc = excelData{row,'SaveLocation'}; saveLoc = saveLoc{1};
    mouseName = excelData{row,'Mouse'}; mouseName = mouseName{1};
    sessionType = excelData{row,'Session'}; sessionType = sessionType{1}(3:end-2);
    system = excelData{row,'System'}; system = system{1};
    samplingRate = excelData{row,'SamplingRate'};
    runTime=excelData{row,'RunTime'};
    
    dataLoc = fullfile(rawDataLoc,recDate); % where raw data is located
    D = dir(dataLoc); D(1:2) = []; %number of runs
    
    % find out valid files
    validFile = false(1,numel(D));
    
    if contains(system,'EastOIS2')
         for file = 1:numel(D)
             validFile(file)= contains(D(file).name,'.mat') ...
                 && contains(D(file).name,sessionType) ...
                 && contains(D(file).name,['-' mouseName '-']);
         end    
    else     
        for file = 1:numel(D)
             validFile(file) = contains(D(file).name,'.tif') ...
                && contains(D(file).name,sessionType) ...
                && contains(D(file).name,['-' mouseName '-']);
         end
    end
    validFiles = D(validFile);
    
    % find list of runs in this mouse
    runList = nan(1,numel(validFiles));
    for file = 1:numel(validFiles)
        runNumStart = strfind(validFiles(file).name,['-' sessionType]);
        runNumStart = runNumStart + numel(sessionType) + 1;
        if isstrprop(validFiles(file).name(runNumStart+1),'digit') %make sure to detect two digit run#
            runNumEnd = runNumStart+1;
        else
            runNumEnd = runNumStart;
        end
%         runNumEnd = find(isstrprop(validFiles(file).name,'digit')); Wrong
%         way to find the second digit
%         runNumEnd(runNumEnd < runNumStart) = [];
        if  contains(system,'EastOIS2')
        runList(file) = str2double(validFiles(file).name(runNumStart:runNumEnd));
        else
        runList(file) = str2double(validFiles(file).name(runNumStart:end-4));
   
        end
    end
    
    uniqueRuns = unique(runList);
    
 % only consider good runs
    goodRuns = uniqueRuns;
    if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'GoodRuns'))) > 0
       goodRuns = excelData{row,'GoodRuns'};
       goodRuns = cellfun(@str2double,strsplit(goodRuns{1},','));
        if sum(isnan(goodRuns))>0;
            goodRuns=uniqueRuns;
        end
        disp(['GoodRuns overwritten with excel for row ' num2str(row+1)]);
    end
    goodRunBool = false(1,numel(uniqueRuns));
    for ind = 1:numel(uniqueRuns)
        goodRunBool(ind) = sum(uniqueRuns(ind) == goodRuns) > 0;
    end
    uniqueRuns = uniqueRuns(goodRunBool);
% Eliminate bad runs
    badRuns = [];
    if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'BadRuns'))) > 0
        badRuns = excelData{row,'BadRuns'};
        badRuns = cellfun(@str2double,strsplit(badRuns{1},','));
        disp(['BadRuns overwritten with excel for row ' num2str(row+1)]);
    end
    goodRunBool = false(1,numel(uniqueRuns));
    for ind = 1:numel(uniqueRuns)
        goodRunBool(ind) = sum(uniqueRuns(ind) == badRuns) == 0;
    end
    uniqueRuns = uniqueRuns(goodRunBool);
%Are there bad presentations?
    badPres_all=[];
    if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'BadPres'))) > 0
        badPres_all = excelData{row,'BadPres'};
        badPres_all = strsplit(badPres_all{1},',');
    end
    
    % for each run, create a listing on output
    for run = uniqueRuns

        %find bad presentations
        if ~isempty(badPres_all)
           badPres_run=badPres_all( ~cellfun(@isempty,strfind(badPres_all,num2str(run))));
           for i=1:numel(badPres_run)
               BadPres(i) = double( extractAfter(badPres_run{i},'.'))-96;               
           end
        else
            BadPres =[];
        end


        totalRunInd = totalRunInd + 1;

        runFiles = validFiles(run == runList);
        
        runFilesList = cell(1,numel(runFiles));
        for file = 1:numel(runFiles)
            runFilesList{file} = fullfile(runFiles(file).folder,runFiles(file).name);
        end
        
        % default
        qc = true;
        samplingRateHb = samplingRate; % hb sampling rate
        samplingRateFluor = samplingRate;
        samplingRateCbf = samplingRate;
        stimRoiSeed = [63 30]/128;
        stimStartTime = 5;
        stimEndTime = 10;
        blockLen = 60;
        affineTransform = true;
        window = [-5 5 -5 5]; % y min, y max, x min, x max (in mm)
        numDarkFrames = 0;
        detrendHb = 1;
        detrendFluor = 1;
        saveRaw = 0;
        
        % get common file name for both mask and data files
        saveFolder = fullfile(saveLoc,recDate);
        runNumStart = strfind(runFiles(1).name,['-' sessionType]);
        saveFileName = runFiles(1).name; saveFileName = saveFileName(1:runNumStart-1);
        
        % get mask file name
        saveMaskFile = [saveFileName '-LandmarksAndMask.mat'];
        saveMaskFile = fullfile(saveLoc,recDate,saveMaskFile);
        
        % get data file name
        saveFilePrefix = [saveFileName '-' sessionType num2str(run)];
        saveFilePrefix = fullfile(saveLoc,recDate,saveFilePrefix);
        saveRawFile = [saveFileName '-' sessionType num2str(run) '-dataRaw.mat'];
        saveRawFile = fullfile(saveLoc,recDate,saveRawFile);
        saveHbFile = [saveFileName '-' sessionType num2str(run) '-dataHb.mat'];
        saveHbFile = fullfile(saveLoc,recDate,saveHbFile);
        saveFluorFile = [saveFileName '-' sessionType num2str(run) '-dataFluor.mat'];
        saveFluorFile = fullfile(saveLoc,recDate,saveFluorFile);
        saveFADFile = [saveFileName '-' sessionType num2str(run) '-dataFAD.mat'];
        saveFADFile = fullfile(saveLoc,recDate,saveFADFile);        
        saveCbfFile = [saveFileName '-' sessionType num2str(run) '-dataCbf.mat'];
        saveCbfFile = fullfile(saveLoc,recDate,saveCbfFile);
        
        % get qc file name
        saveRawQCFig = [saveFileName '-' sessionType num2str(run) '-rawQC'];
        saveRawQCFig = fullfile(saveLoc,recDate,saveRawQCFig);
        saveFCQCFig = [saveFileName '-' sessionType num2str(run) '-fcQC'];
        saveFCQCFig = fullfile(saveLoc,recDate,saveFCQCFig);
        saveStimQCFig = [saveFileName '-' sessionType num2str(run) '-stimQC'];
        saveStimQCFig = fullfile(saveLoc,recDate,saveStimQCFig);
        saveRawQCFile = [saveFileName '-' sessionType num2str(run) '-rawQC.mat'];
        saveRawQCFile = fullfile(saveLoc,recDate,saveRawQCFile);
        saveFCQCFile = [saveFileName '-' sessionType num2str(run) '-fcQC.mat'];
        saveFCQCFile = fullfile(saveLoc,recDate,saveFCQCFile);
        saveStimQCFile = [saveFileName '-' sessionType num2str(run) '-stimQC.mat'];
        saveStimQCFile = fullfile(saveLoc,recDate,saveStimQCFile);
        
        % get system info and values dependent on system
        systemInfo = sysInfo(system);
        numCh = systemInfo.numLEDs;
        lightSourceFiles = systemInfo.LEDFiles;
        fluorFiles = systemInfo.fluorFiles;
        FADFiles = systemInfo.FADFiles;        
        rgbInd = systemInfo.rgb;
        gbox = systemInfo.gbox;
        gsigma = systemInfo.gsigma;
        validThr = systemInfo.validThr;
        numInvalidFrames = systemInfo.numInvalidFrames;
        binFactor = systemInfo.binFactor;
        hbChInd = systemInfo.chHb;
        fluorChInd = systemInfo.chFluor;
        FADChInd=systemInfo.chFAD;
        speckleChInd = systemInfo.chSpeckle;
        laserChInd = systemInfo.chLaser;%%xw 220603 add laser        
        Contrasts=systemInfo.Contrasts;
        % check if these values are stated in excel. If so, override.
        variableNames = {'NumCh','HbChInd','FluorChInd','SpeckleChInd','RGBInd',...
            'GBox','GSigma','ValidThreshold','NumDarkFrames','NumInvalidFrames',...
            'DetrendHb','DetrendFluor','SaveRaw','SaveMaskFile','SaveRawFile',...
            'SaveHbFile','SaveFluorFile','SaveCbfFile','QC','SamplingRateHb',...
            'SamplingRateFluor','SamplingRateCbf','StimRoiSeed','StimStartTime','StimEndTime',...
            'BlockLen','BinFactor','AffineTransform','Window','FADChInd'};
        expectedType = [1,1,1,1,1,...g
            1,1,1,1,1,...
            1,1,1,2,2,...
            2,2,2,1,1,...
            1,1,1,1,1,...
            1,1,1,1,1]; % 1 means double, 2 means char
        defaultVal = {numCh,hbChInd,fluorChInd,speckleChInd,rgbInd,...
            gbox,gsigma,validThr,numDarkFrames,numInvalidFrames,...
            detrendHb,detrendFluor,saveRaw,saveMaskFile,saveRawFile,...
            saveHbFile,saveFluorFile,saveCbfFile,qc,samplingRateHb,...
            samplingRateFluor,samplingRateCbf,stimRoiSeed,stimStartTime,stimEndTime,...
            blockLen,binFactor,affineTransform,window,FADChInd};
        
        for varInd = 1:numel(variableNames)
            varOutName = variableNames{varInd}; varOutName(1) = lower(varOutName(1));
            eval([varOutName ' = defaultVal{varInd};']); % define default values
            varExists = sum(~cellfun(@isempty,strfind(...
                excelData.Properties.VariableNames,variableNames{varInd}))) > 0;
            if varExists
                cellData = excelData{row,variableNames{varInd}};
                if expectedType(varInd) == 1 % expected double
                    if iscell(cellData)
                        if ~isempty(cellData)
                            cellData = cellfun(@str2double,strsplit(cellData{1},','));
                            eval([varOutName ' = cellData;']);
                        end
                    elseif isnan(cellData)
                    else
                        eval([varOutName ' = cellData;']);
                    end
                elseif expectedType(varInd) == 2 % expected char array
                    if iscell(cellData) && ~isempty(cellData)
                        eval([varOutName ' = cellData;']);
                    end
                end
            end
        end
        
        darkFramesInd = 1:numDarkFrames;
        invalidFramesInd = 1:numInvalidFrames;
        
        % add to struct
        runsInfo(totalRunInd).excelRow = row + 1;
        runsInfo(totalRunInd).excelRow_char = num2str(row + 1);
        runsInfo(totalRunInd).mouseName = mouseName;
        runsInfo(totalRunInd).recDate = recDate;
        runsInfo(totalRunInd).run = run;
        runsInfo(totalRunInd).runTime=runTime; %jpcAdded
        runsInfo(totalRunInd).totNum_frame=runTime*samplingRate*numCh+(numCh*darkFramesInd(end)); 
        runsInfo(totalRunInd).samplingRate = samplingRate;
        runsInfo(totalRunInd).samplingRateHb = samplingRateHb;
        runsInfo(totalRunInd).samplingRateFluor = samplingRateFluor;
        runsInfo(totalRunInd).samplingRateCbf = samplingRateCbf;
        if isempty(darkFramesInd)
            runsInfo(totalRunInd).totNum_frame=runTime*samplingRate*numCh;
        else
            runsInfo(totalRunInd).totNum_frame=runTime*samplingRate*numCh+(numCh*darkFramesInd(end)); 
        end       
        runsInfo(totalRunInd).numInvalidFrames=numInvalidFrames;
        runsInfo(totalRunInd).darkFramesInd=darkFramesInd;
        runsInfo(totalRunInd).invalidFramesInd = invalidFramesInd;
        runsInfo(totalRunInd).rawFile = runFilesList;
        runsInfo(totalRunInd).lightSourceFiles = lightSourceFiles;
        runsInfo(totalRunInd).fluorFiles = fluorFiles;
        runsInfo(totalRunInd).FADFiles = FADFiles;
        runsInfo(totalRunInd).numCh = numCh;
        runsInfo(totalRunInd).binFactor = binFactor;
        runsInfo(totalRunInd).rgbInd = rgbInd;
        runsInfo(totalRunInd).hbChInd = hbChInd;
        runsInfo(totalRunInd).fluorChInd = fluorChInd;
        runsInfo(totalRunInd).FADChInd = FADChInd;
        runsInfo(totalRunInd).speckleChInd = speckleChInd;
        runsInfo(totalRunInd).laserChInd = laserChInd;        
        runsInfo(totalRunInd).window = window;
        runsInfo(totalRunInd).gbox = gbox;
        runsInfo(totalRunInd).gsigma = gsigma;
        runsInfo(totalRunInd).detrendHb = detrendHb;
        runsInfo(totalRunInd).detrendFluor = detrendFluor;
        runsInfo(totalRunInd).Contrasts = Contrasts;        
        runsInfo(totalRunInd).qc = qc;
        runsInfo(totalRunInd).stimRoiSeed = stimRoiSeed;
        runsInfo(totalRunInd).stimStartTime = stimStartTime;
        runsInfo(totalRunInd).stimEndTime = stimEndTime;
        runsInfo(totalRunInd).blockLen = blockLen;
        runsInfo(totalRunInd).validThr = validThr;
        runsInfo(totalRunInd).saveRaw = saveRaw;
        runsInfo(totalRunInd).saveFolder = saveFolder;
        runsInfo(totalRunInd).saveMaskFile = saveMaskFile;
        runsInfo(totalRunInd).saveFilePrefix = saveFilePrefix;
        runsInfo(totalRunInd).saveRawFile = saveRawFile;
        runsInfo(totalRunInd).saveHbFile = saveHbFile;
        runsInfo(totalRunInd).saveFluorFile = saveFluorFile;
        runsInfo(totalRunInd).saveCbfFile = saveCbfFile;
        runsInfo(totalRunInd).saveRawQCFig = saveRawQCFig;
        runsInfo(totalRunInd).saveFCQCFig = saveFCQCFig;
        runsInfo(totalRunInd).saveStimQCFig = saveStimQCFig;
        runsInfo(totalRunInd).saveRawQCFile = saveRawQCFile;
        runsInfo(totalRunInd).saveFCQCFile = saveFCQCFile;
        runsInfo(totalRunInd).saveStimQCFile = saveStimQCFile;
        runsInfo(totalRunInd).saveFADFile = saveFADFile;               
        runsInfo(totalRunInd).system = system;
        runsInfo(totalRunInd).session = sessionType;
        runsInfo(totalRunInd).affineTransform = affineTransform;
        runsInfo(totalRunInd).BadPres=BadPres; 
    end

end
end

