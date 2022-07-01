function  [fh,peakMaps] = generateBlockMap_Dynamics(data,data_gsr,runInfo,numBlocks,peakRange,isbrain,ROIMask)
% pres of each block during stim period

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

OGsize=size(data_gsr);
Mask_ind=find(ROIMask.*isbrain);

parampath=what('bauerparams');
load(which('noVasculatureMask.mat')) 
mask_new = logical(mask_new);
numRows = length(runInfo.Contrasts);
fh = figure('units','normalized','outerposition',[0 0 1 1]);
colormap jet
peakMaps = nan(128,128,numBlocks+1,numRows);
for ii = 1:numBlocks+1

    for jj = 1:numRows+1
        if jj<=numRows
            peakMap = squeeze(mean(data_gsr(:,:,:,:,jj),4));
            peakMap = squeeze(mean(peakMap(:,:,(round(peakRange{jj}(1)*runInfo.samplingRate)):(round(peakRange{jj}(end)*runInfo.samplingRate))),3));
            maxVal = prctile(abs(peakMap(mask_new)),90,'all')*2.5;
            maxVal = round(maxVal,2,'significant');
            p = subplot(numRows+1,numBlocks+1,(numBlocks+1)*(jj-1)+ii);
            if ii == numBlocks+1
                imagesc(peakMap,'AlphaData',isbrain,[-maxVal,maxVal])
                peakMaps(:,:,ii,jj) = peakMap;                
                axis image
                set(gca, 'XTick', []);
                set(gca, 'YTick', []);
                title('Averaged')
                Pos = get(p,'Position');
                cb = colorbar;
                caxis([-maxVal maxVal])
                set(p,'Position',Pos)
                set(cb,'YTick',[-maxVal,0,maxVal]);

                if sum(contains({'HbO','HbR','HbT'},runInfo.Contrasts{jj}))>0
                    set(get(cb,'label'),'string','Hb(\Delta\muM)');
                elseif sum(contains({'Calcium','FAD'},runInfo.Contrasts{jj}))>0
                    set(get(cb,'label'),'string','Fluorescence(\DeltaF/F%)');
                end
            else
                pre = squeeze(mean(data_gsr(:,:,(round(peakRange{jj}(1)*runInfo.samplingRate)):(round(peakRange{jj}(end)*runInfo.samplingRate)),ii,jj),3));
                imagesc(pre,'AlphaData',isbrain,[-maxVal,maxVal]);
                peakMaps(:,:,ii,jj) = pre;
                
                axis image
                set(gca, 'XTick', []);
                set(gca, 'YTick', []);
                if jj==1
                    title(strcat('Pres',{' '},num2str(ii)))
                end
                if ii == 1
                    ylabel(runInfo.Contrasts{jj},'Color',sysInfo(runInfo.system).colors{jj})
                end
            end

        else %Plot dynamics
            data_dynam=data;
            data_dynam=reshape(data_dynam,OGsize(1)*OGsize(2),[],numBlocks,numel(runInfo.Contrasts));
            data_dynam=data_dynam(Mask_ind,:,:,:);

            p = subplot(numRows+1,numBlocks+1,(numBlocks+1)*(jj-1)+ii);

            if ii~=numBlocks+1

                for jjj=1:numel(runInfo.Contrasts)
                    if sum(contains({'HbO','HbR','HbT'},runInfo.Contrasts{jjj}))>0
                    yyaxis left                        
                    plot(squeeze(squeeze(mean(data_dynam(:,:,ii,jjj),'omitnan'))),'Color',sysInfo(runInfo.system).colors{jjj})
                    hold on
                    ylabel('[Hb](\Delta\muM)');
                    elseif sum(contains({'Calcium','FAD'},runInfo.Contrasts{jjj}))>0
                    yyaxis right
                    plot(squeeze(squeeze(mean(data_dynam(:,:,ii,jjj),'omitnan'))),'Color',sysInfo(runInfo.system).colors{jjj})
                    hold on                        
                    ylabel('Fluoro(\DeltaF/F%)');
                    end
                end
                grid on
                ylimz=ylim;
                ylim([ylimz(1)+.1*ylimz(1),ylimz(2)+.1*ylimz(2) ])

                xlim([runInfo.stimStartTime*runInfo.samplingRate-3*runInfo.samplingRate runInfo.stimEndTime*runInfo.samplingRate+3*runInfo.samplingRate])   %halft second before to full second after
                xticks([runInfo.stimEndTime*runInfo.samplingRate-(2/3)*runInfo.stimEndTime*runInfo.samplingRate,...
                    runInfo.stimEndTime*runInfo.samplingRate-(1/3)*runInfo.stimEndTime*runInfo.samplingRate,...
                    runInfo.stimEndTime*runInfo.samplingRate])
                xticklab=[0,( runInfo.stimEndTime-runInfo.stimStartTime)/2, runInfo.stimEndTime-runInfo.stimStartTime];
                xticklabels({num2str(xticklab(1)), num2str(xticklab(2)),num2str(xticklab(3))})
            else
                for jjj=1:numel(runInfo.Contrasts)
                    if sum(contains({'HbO','HbR','HbT'},runInfo.Contrasts{jjj}))>0
                    yyaxis left                        
                    plot(squeeze(squeeze(squeeze(mean(mean(data_dynam(:,:,:,jjj),3,'omitnan'),'omitnan')))),'Color',sysInfo(runInfo.system).colors{jjj})
                    hold on
                    ylabel('[Hb](\Delta\muM)');
                    elseif sum(contains({'Calcium','FAD'},runInfo.Contrasts{jjj}))>0
                    yyaxis right
                    plot(squeeze(squeeze(squeeze(mean(mean(data_dynam(:,:,:,jjj),3,'omitnan'),'omitnan')))),'Color',sysInfo(runInfo.system).colors{jjj})
                    hold on                        
                    ylabel('Fluoro(\DeltaF/F%)');
                    end
                end

                grid on
                ylimz=ylim;
                ylim([ylimz(1)+.1*ylimz(1),ylimz(2)+.1*ylimz(2) ])

                xlim([runInfo.stimStartTime*runInfo.samplingRate-3*runInfo.samplingRate runInfo.stimEndTime*runInfo.samplingRate+3*runInfo.samplingRate])   %halft second before to full second after
                xticks([runInfo.stimEndTime*runInfo.samplingRate-(2/3)*runInfo.stimEndTime*runInfo.samplingRate,...
                    runInfo.stimEndTime*runInfo.samplingRate-(1/3)*runInfo.stimEndTime*runInfo.samplingRate,...
                    runInfo.stimEndTime*runInfo.samplingRate])
                xticklab=[0,( runInfo.stimEndTime-runInfo.stimStartTime)/2, runInfo.stimEndTime-runInfo.stimStartTime];
                xticklabels({num2str(xticklab(1)), num2str(xticklab(2)),num2str(xticklab(3))})
            end

            xline(runInfo.stimEndTime*runInfo.samplingRate)
            xline(runInfo.stimStartTime*runInfo.samplingRate)

            Ax = gca;
            xt = Ax.XTick;
            Ax.XTickLabel = xt/runInfo.samplingRate-runInfo.stimStartTime;
            Ax.XLabel.String = 'Time (sec)';

            xlabel('Time (sec)')

        end
    end
end


end
