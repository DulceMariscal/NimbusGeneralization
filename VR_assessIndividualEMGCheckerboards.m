%This file will run EMG regressions and plot checkerboards.
% 1)load data; assuming the data is saved under currentDir/data/
% 2)plot checkboards for all relevant epochs, save figures, can be turned
% off by setting plotAllEpoch to false
% 3)plot checkboards for regression related epoch (regressors), save figures, 
%run regression and save the model results.
% - can plot and run regression for both indidual subjects or group subjects (only enabled if more than 1 subjects id provided),
% turn off individual subjects plotting by setting to false

%% Load data and Plot checkerboard for all conditions.
clear; close all; clc;

% set script parameters, SHOULD CHANGE/CHECK THIS EVERY TIME.
groupID = 'VROG';
saveResAndFigure = true;
plotAllEpoch = false;
plotIndSubjects = false;

scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 
files = dir ([scriptDir '/data/' groupID '*params.mat']);
n_subjects = size(files,1);
subID = cell(1, n_subjects);
sub=cell(1,n_subjects);
for i = 1:n_subjects
    sub{i} = files(i).name;
    subID{i} = sub{i}(1:end-10);
end
subID

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
if plotAllEpoch
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
        set(gcf,'color','w');

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
end
%% Regressor V2, prepare data for regressor checkerboards and regression model
% - Update from disucssion on Tuesday MAy 4, 2021
% - Refer to OneNote for naming details

% Adapt VR- baseline VR
% OG base - baseline VR 
% baseline - EMG_split(-)

usefft = 0; normalizeData = 0; 
ep=defineEpochVR_OG_UpdateV1('nanmean');
refEpAdaptLate = defineReferenceEpoch('Task_{Switch}',ep);

refEpOGBase=defineReferenceEpoch('OGbase',ep);
refEpOGpost= defineReferenceEpoch('OGpost_{Late}',ep);
refEp= defineReferenceEpoch('TMbase',ep);

%% plot checkerboard and run regression per subject
if plotIndSubjects || length(subID) == 1
    close all;
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
        set(gcf,'color','w');
        
        resDir = [scriptDir '/RegressionAnalysis/RegModelResults/'];
        if (saveResAndFigure)
            if not(isfolder(resDir))
                mkdir(resDir)
            end
            saveas(fh, [resDir subID{i} '_Checkerboard_ver' num2str(usefft) num2str(normalizeData) '.png'])
        end
        
        % run regression and save results
        format compact % format loose %(default)
        %     not normalized first, then normalized
        runRegression(Data, false, false, subID{i}, resDir, saveResAndFigure, usefft)
        runRegression(Data, true, false, subID{i}, resDir, saveResAndFigure, usefft)
        %     (Data, normalizeData, isGroupData, dataId, resDir, saveResAndFigure, usefft) 

    end
end
%% plot checkerboards and run regression per group
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
    
    resDir = [scriptDir '/RegressionAnalysis/RegModelResults/GroupResults/'];
    if (saveResAndFigure)    
        if not(isfolder(resDir))
            mkdir(resDir)
        end
        saveas(fh, [resDir groupID '_group_Checkerboard_ver' num2str(usefft) num2str(normalizeData) '.png'])
    end

    % run regression and save results
    format compact % format loose %(default)
%     not normalized first, then normalized
    runRegression(Data, false, true, groupID, resDir, saveResAndFigure, usefft)
    runRegression(Data, true, true, groupID, resDir, saveResAndFigure, usefft)
%     (Data, normalizeData, isGroupData, dataId, resDir, saveResAndFigure, usefft) 
end