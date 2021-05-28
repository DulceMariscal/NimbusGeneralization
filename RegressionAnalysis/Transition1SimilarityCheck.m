scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 
subID = {'NimbG_BoyanAllMuscles'}
sub={};
for i = 1 : length(subID)
    sub{i} = [subID{i} 'params']; %this file might be under a data directory
end
%% Similarity of emgc1ep ~ emg c1 o
n_subjects = length(subID);
% TODO: works for VR group only
ep=defineEpochVR_OG_UpdateV1('nanmean');
[normalizedTMFullAbrupt, refEp, newLabelPrefix] = getNormalizedDataWithCleanLabels(sub, ep);

for i = 1:n_subjects

    adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i}; 

    fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
    ph=tight_subplot(1,2,[.03 .005],.04,.04);
    flip=true;
    
    Data = {}; %in order: adapt, dataEnvSwitch, dataTaskSwitch, dataTrans1, dataTrans2
    [~,~,labels,Data{1},dataRef2]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(1,:),fh,ph(1,1),[],flip); %  EMG_split(-) - TM base VR, adaptation
    [~,~,~,Data{2},~]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(9,:),fh,ph(1,2),[],flip); %  EMG_split(-) - TM base VR, adaptation
    
    
    set(ph(:,1),'CLim',[-1 1]);
    set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1.5);
    set(ph,'FontSize',8)
    pos=get(ph(1,end),'Position');
    axes(ph(1,end))
    colorbar
    set(ph(1,end),'Position',pos);
    saveas(fh, [scriptDir '/RegModelResults/' subID{i} 'Trans1SimilarityCheckerboard.png'])
end
set(gcf,'color','w');

%% Regress the 2, correlation check
clc;
for i = 1:size(Data,2)
    Data{i} = reshape(Data{i}, [],1); %make it a column vector
end
[r, p] = corr(Data{1}, Data{2}) %default pearson

tableData=table(Data{1},Data{2},'VariableNames',{'OGBase', 'OGEarlyPost'});%C1_0(C1_EP)
fitTrans1SimilarityNoConst=fitlm(tableData,'OGBase ~ OGEarlyPost-1')%exclude constant
Rsquared = fitTrans1SimilarityNoConst.Rsquared
fitTrans1Similarity=fitlm(tableData,'OGBase ~ OGEarlyPost')%exclude constant