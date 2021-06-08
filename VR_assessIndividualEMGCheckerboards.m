%% Load data and Plot checkerboard for all conditions.
clear; close all; clc;
subID = {'CVROG_01','CVROG_02'};
sub={};
scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 

for i = 1 : length(subID)
    sub{i} = [subID{i} 'params'];
end

groupID = 'CVROG';
saveResAndFigure = false;

%% load and prep data
normalizedTMFullAbrupt=adaptationData.createGroupAdaptData(sub);

ss =normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');

% ss =TMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm'); %Dulce 
s2 = regexprep(ss,'^Norm','dsjrs');
normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ss,s2);
% normalizedTMFullAbrupt=studyData.TMFullAbrupt.renameParams(ss,s2);

% muscleOrder={'TA','MG','SEMT','VL','RF'};
muscleOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'HIP'};

n_muscles = length(muscleOrder);


n_subjects = length(subID);
extremaMatrixYoung = NaN(n_subjects,n_muscles * 2,2);


ep=defineEpochVR_OG('nanmean');
refEp = defineReferenceEpoch('TMbase',ep);
refEpLate = defineReferenceEpoch('Adaptation',ep);
% refEp = defineEpochYoungLongAdaptation('Fast',ep);

newLabelPrefix = defineMuscleList(muscleOrder);

% normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,ep(1,:));
normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,refEp);


ll=normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');
%ll = normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^(s|f)[A-Z]+_s');

l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ll,l2);

newLabelPrefix = regexprep(newLabelPrefix,'_s','s');

%% plot epochs
for i = 1:n_subjects
    

    adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i}; 

    fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
    ph=tight_subplot(1,length(ep)+1,[.03 .005],.04,.04);
    flip=true;

    adaptDataSubject.plotCheckerboards(newLabelPrefix,refEp,fh,ph(1,1),[],flip); %First, plot reference epoch:   
    [~,~,labels,dataE{i},dataRef{i}]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep,fh,ph(1,2:end),refEp,flip);%Second, the rest:
    adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(7,:),fh,ph(1,8),refEpLate,flip);%Second, the rest:
    
    
    set(ph(:,1),'CLim',[-1 1]);
%     set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*2);
    set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1.5);
    set(ph,'FontSize',8)
    pos=get(ph(1,end),'Position');
    axes(ph(1,end))
    colorbar
    set(ph(1,end),'Position',pos);
       
    extremaMatrixYoung(i,:,1) =  min(dataRef{1});
    extremaMatrixYoung(i,:,2) =  max(dataRef{1});
    if (saveResAndFigure)
        resDir = [scriptDir '/RegressionAnalysis/RegModelResults/'];
        if not(isfolder(resDir))
            mkdir(resDir)
        end
        saveas(fh, [resDir subID{i} '_AllEpochCheckerBoard.png']) 
    end
end
set(gcf,'color','w');

% [data,validStrides,allData]=getEpochData(adaptDataSubject,ep(1,:),newLabelPrefix);
% [dataE,labels]=adaptDataSubject.getPrefixedEpochData(newLabelPrefix,ep,false);

%% Regressor V2, prepare data for regressor checkerboards and regression model
% - Update from disucssion on Tuesday MAy 4, 2021
% - Refer to OneNote for naming details

% Adapt VR- baseline VR
% OG base - baseline VR 
% baseline - EMG_split(-)

normalizedTMFullAbrupt=adaptationData.createGroupAdaptData(sub);

ss =normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');

% ss =TMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm'); %Dulce 
s2 = regexprep(ss,'^Norm','dsjrs');
normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ss,s2);
% normalizedTMFullAbrupt=studyData.TMFullAbrupt.renameParams(ss,s2);

% muscleOrder={'TA','MG','SEMT','VL','RF'};
muscleOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'HIP'};
% muscleOrder={'TA', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'HIP'};

n_muscles = length(muscleOrder);
useLateAdaptAsBaseline=false;

usefft = 0; normalizeData = 0; 
ep=defineEpochVR_OG_UpdateV1('nanmean');
refEpAdaptLate = defineReferenceEpoch('Task_{Switch}',ep);

refEpOGBase=defineReferenceEpoch('OGbase',ep);
refEpOGpost= defineReferenceEpoch('OGpost_{Late}',ep);
refEp= defineReferenceEpoch('TMbase',ep);


newLabelPrefix = defineMuscleList(muscleOrder);

normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,refEp); %Normalized by the TM base w VR 


ll=normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');
%ll = normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^(s|f)[A-Z]+_s');

l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ll,l2);

newLabelPrefix = regexprep(newLabelPrefix,'_s','s');

%% plot checkerboard per subject
close all;
n_subjects = length(subID);
% extremaMatrixYoung = NaN(n_subjects,n_muscles * 2,2);

for i = 1:n_subjects

    adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i}; 

    fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
    ph=tight_subplot(1,5,[.03 .005],.04,.04);
    flip=true;
    
    Data = {}; %in order: adapt, dataEnvSwitch, dataTaskSwitch, dataTrans1, dataTrans2
    if usefft
        [~,~,labels,Data{1},dataRef2]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(4,:),fh,ph(1,1),refEp,flip); %  EMG_split(-) - TM base VR, adaptation
    else
        [~,~,labels,Data{1},dataRef2]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(3,:),fh,ph(1,1),refEp,flip); %  EMG_split(-) - TM base VR, adaptation
    end
    %all labels should be the same, no need to save again.
    [~,~,~,Data{2},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(5,:),fh,ph(1,2),refEpOGBase,flip); % TM base VR - OG base, env switching
    [~,~,~,Data{3},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(7,:),fh,ph(1,3),ep(6,:),flip); % Adapt SS - baseline TM, task switching (within env)
    [~,~,~,Data{4},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(8,:),fh,ph(1,4),refEpAdaptLate,flip); %OGafter - Adaptation_{SS}, transition 1 
    [~,~,~,Data{5},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(11,:),fh,ph(1,5),refEpOGpost,flip); %TM post VR early - OG post late, transition 2
%     [~,~,labels,dataE{1},dataRef{1}]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep,fh,ph(1,2:end),refEp,flip);%Second, the rest:
    
    set(ph(:,1),'CLim',[-1 1]);
%     set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*2);
    set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1.5);
    set(ph,'FontSize',8)
    pos=get(ph(1,end),'Position');
    axes(ph(1,end))
    colorbar
    set(ph(1,end),'Position',pos);
    
    if (saveResAndFigure)
        resDir = [scriptDir '/RegressionAnalysis/RegModelResults/'];
        if not(isfolder(resDir))
            mkdir(resDir)
        end
        saveas(fh, [resDir subID{i} '_Checkerboard_ver' num2str(usefft) num2str(normalizeData) '.png'])
    end
end
set(gcf,'color','w');

%% plot checkerboards per group
if length(subID) > 1
    fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
    ph=tight_subplot(1,5,[.03 .005],.04,.04);
    flip=true;

    Data = {}; %in order: adapt, dataEnvSwitch, dataTaskSwitch, dataTrans1, dataTrans2
    if usefft
        [~,~,labels,Data{1},dataRef2]=normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(4,:),fh,ph(1,1),refEp,flip); %  EMG_split(-) - TM base VR, adaptation
    else
        [~,~,labels,Data{1},dataRef2]=normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(3,:),fh,ph(1,1),refEp,flip); %  EMG_split(-) - TM base VR, adaptation
    end
    %all labels should be the same, no need to save again.
    [~,~,~,Data{2},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(5,:),fh,ph(1,2),refEpOGBase,flip); % TM base VR - OG base, env switching
    [~,~,~,Data{3},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(7,:),fh,ph(1,3),ep(6,:),flip); % Adapt SS - baseline TM, task switching (within env)
    [~,~,~,Data{4},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(8,:),fh,ph(1,4),refEpAdaptLate,flip); %OGafter - Adaptation_{SS}, transition 1
    [~,~,~,Data{5},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(11,:),fh,ph(1,5),refEpOGpost,flip); %TM post VR early - OG post late, transition 2
    %     [~,~,labels,dataE{1},dataRef{1}]=normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep,fh,ph(1,2:end),refEp,flip);%Second, the rest:

    set(ph(:,1),'CLim',[-1 1]);
    %     set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*2);
    set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1.5);
    set(ph,'FontSize',8)
    pos=get(ph(1,end),'Position');
    axes(ph(1,end))
    colorbar
    set(ph(1,end),'Position',pos);

    set(gcf,'color','w');
end

if (saveResAndFigure)
    resDir = [scriptDir '/RegressionAnalysis/RegModelResults/AllSubjectsOrGroupResults/'];
    if not(isfolder(resDir))
        mkdir(resDir)
    end
    saveas(fh, [resDir groupID '_group_Checkerboard_ver' num2str(usefft) num2str(normalizeData) '.png'])
end

%% Prepare data for regression analysis V2
%handling nan value?
%normalize data? 
clc;
if length(subID) == 1
    for i = 1:size(Data,2)
        Data{i} = reshape(Data{i}, [],1); %make it a column vector
    end
else %group data, take the median
    rawData = Data;
    for i = 1:size(Data,2)
        d = nanmedian(Data{i}, 4);
        Data{i} = reshape(d, [],1); %make it a column vector
    end
end

if usefft %do fft - run only once
    Data{size(Data,2) + 1} = Data{1}; %store the current on to the last
    Data{1} = fftshift(Data{1},1);
end
%% 
clc
format compact
for normIndex = 0:1
    fprintf('\n\n')
    normalizeData = normIndex
    if normalizeData
        DataOriginal = Data;
        for i = 1:size(Data,2)
            Data{i} = Data{i}/norm(Data{i});
        end
    end

    % for i = 1:size(Data,2)
    %     norm(Data{i})
    % end
    %%% Run regression analysis V2
    tableData=table(Data{1},Data{2},Data{3},Data{4},Data{5},'VariableNames',{'Adapt', 'EnvSwitch', 'TaskSwitch', 'Trans1', 'Trans2'});
    fitTrans1NoConst=fitlm(tableData,'Trans1 ~ TaskSwitch+EnvSwitch+Adapt-1')%exclude constant
    Rsquared = fitTrans1NoConst.Rsquared

    fprintf('\n\n\n')

    fitTrans2NoConst=fitlm(tableData,'Trans2 ~ TaskSwitch+EnvSwitch+Adapt-1')%exclude constant
    Rsquared = fitTrans2NoConst.Rsquared

    %compute and print out relative vector norm to assess the length
    %difference between regressors
    fprintf('\n\n')
    vec_norm = vecnorm(fitTrans1NoConst.Variables{:,:});
    relNom = normalize(vec_norm,'norm',1)
    
    scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 
    if saveResAndFigure
        resDir = [scriptDir '/RegressionAnalysis/RegModelResults/'];
        if not(isfolder(resDir))
            mkdir(resDir)
        end

        if length(subID) == 1
            save([resDir, subID{1}, 'models_ver' num2str(usefft) num2str(normalizeData)], 'fitTrans1NoConst','fitTrans2NoConst')
        else
            %version convention: first digit: use fft or not (usually 0), 2nd digit: normalize or not
            save([resDir 'AllSubjectsOrGroupResults/' groupID '_group_models_ver' num2str(usefft) num2str(normalizeData)], 'fitTrans1NoConst','fitTrans2NoConst')
        end
    end
end