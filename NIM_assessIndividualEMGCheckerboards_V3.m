%This file will run EMG regressions and plot checkerboards.
% 1)load data; assuming the data is saved under currentDir/data/
% 2)plot checkboards for all relevant epochs, save figures, can be turned
% off by setting plotAllEpoch to false
% 3)plot checkboards for regression related epoch (regressors), save figures, 
%run regression and save the model results.
% - can plot and run regression for both indidual subjects or group subjects (only enabled if more than 1 subjects id provided),
% turn off individual subjects plotting by setting to false
% The results are saved under
% currentDir/RegressionAnalysis/RegModelResults_V##. If there are code
% changes that's worth a version update, search for _V## and then update
% the version number to avoid overwrite.

%% Update params file condition names to match
% changeCondName('VROG_03',{'TM base', 'OG post','TM post'},{'TR base','Post 1','Post 2'})
% clc;
% load('/Users/mac/Desktop/Lab/SMLLab/Code/R01_MyFork/data/VROG_03params.mat')
% adaptData.metaData.conditionName

%% Load data 
clear; close all; clc;

% load('/Users/samirsherlekar/Desktop/emg/Data/normalizedYoungEmgData.mat');
% load('C:\Users\dum5\Box\GeneralizationStudy Data\NormalizedFastYoungEMGData.mat')
% sub={'YL02params'};

% set script parameters, SHOULD CHANGE/CHECK THIS EVERY TIME.
groupID = 'NTR'; % groupID to grab all subjects from the same group. If only want to grab 1 subject, specify subject ID.
saveResAndFigure = false;
plotAllEpoch = false;
plotIndSubjects = true;
plotGroup = true; %will always plot group if more than 1 subjects provided

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

if (strcmp(groupID, 'NTS'))
    regModelVersion = 'TS'
elseif (strcmp(groupID, 'NTR'))
    regModelVersion = 'TR'
end

%% load and prepare data. 
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

n_subjects = length(subID);
% extremaMatrixYoung = NaN(n_subjects,n_muscles * 2,2);


ep=defineEpochNimbusShoes('nanmean');
refEp = defineReferenceEpoch('OGNimbus',ep);
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

%% remove bad muscles
%NTS: remove sHIP and sVL
% NTR: remove fTFL
if strcmp(groupID, 'NTR')
    badMuscleNames = {'fTFLs'};
elseif strcmp(groupID, 'NTS')
    badMuscleNames = {'sHIPs','sVLs'};
end
if exist('badMuscleNames','var') %check if badMuscleNames is defined, if so update the labels list.
    badMuscleIdx=[];
    for bm = badMuscleNames
        badMuscleIdx = [badMuscleIdx, find(ismember(newLabelPrefix,bm))];
    end
    newLabelPrefix = newLabelPrefix(setdiff(1:end, badMuscleIdx))
end
%% plot all epochs for all relevant conditions
if plotAllEpoch
    for i = 1:n_subjects
        adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i}; 

        fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
        ph=tight_subplot(1,length(ep)+1,[.03 .005],.04,.04);
        flip=true;

        adaptDataSubject.plotCheckerboards(newLabelPrefix,refEp,fh,ph(1,1),[],flip); %First, plot reference epoch:   
        [~,~,labels,dataE{1},dataRef{1}]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep,fh,ph(1,2:end),refEp,flip);%Second, the rest:
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

        if (saveResAndFigure)
            resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V11/'];
            if not(isfolder(resDir))
                mkdir(resDir)
            end
            saveas(fh, [resDir subID{i} '_AllEpochCheckerBoard.png']) 
        end
    end
end
%% Regressor V2 - Update from disucssion on Tuesday MAy 4, 2021 
% Adapt VR- baseline VR
% OG base - baseline VR 
% baseline - EMG_split(-) 

usefft = 0; normalizeData = 0;
ep=defineEpochNIM_OG_UpdateV3('nanmean');
refEpAdaptLate = defineReferenceEpoch('Task_{Switch}',ep);

refEpOGpost= defineReferenceEpoch('Post1_{Late}',ep);
refEp= defineReferenceEpoch('TMbase',ep);

%% Plot checkerboards per subject
if plotIndSubjects || length(subID) == 1
    close all;
    for i = 1:n_subjects

        adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i}; 

        fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
        ph=tight_subplot(1,5,[.03 .005],.04,.04);
        flip=true;

        Data = {}; %in order: adapt, dataEnvSwitch, dataTaskSwitch, dataTrans1, dataTrans2
        %all labels should be the same, no need to save again.
        if usefft
            [~,~,labels,Data{1},dataRef2]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(4,:),fh,ph(1,1),refEp,flip); %  EMG_split(-) - TM base VR, adaptation
        else
            [~,~,labels,Data{1},dataRef2]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(3,:),fh,ph(1,1),refEp,flip); %  EMG_split(-) - TM base VR, adaptation
        end
        [~,~,~,Data{2},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(14,:),fh,ph(1,2),ep(4,:),flip); % Noadapt (env-driven), TM base - EMG_on(+)
        [~,~,~,Data{3},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(1,:),fh,ph(1,3),ep(6,:),flip); %  -(TR base - OG base) = OG base - TR base, env switching
        [~,~,~,Data{4},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(8,:),fh,ph(1,4),refEpAdaptLate,flip); %OGafter - Adaptation_{SS} , transition 1
        [~,~,~,Data{5},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(11,:),fh,ph(1,5),refEpOGpost,flip); %Nimbus post early - OG post late, transition 2
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

%         extremaMatrixYoung(i,:,1) =  min(dataRef2);
%         extremaMatrixYoung(i,:,2) =  max(dataRef2);

        resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V11/'];
        if saveResAndFigure
            if not(isfolder(resDir))
                mkdir(resDir)
            end
            saveas(fh, [resDir subID{i} '_Checkerboard_ver' num2str(usefft) num2str(normalizeData) '.png']) 
        end

        % run regression and save results
        format compact % format loose %(default)
        % not normalized first, then normalized, arugmnets order: (Data, normalizeData, isGroupData, dataId, resDir, saveResAndFigure, version, usefft) 
        runRegression_V3(Data, false, false, subID{i}, resDir, saveResAndFigure, regModelVersion, usefft)
        runRegression_V3(Data, true, false, subID{i}, resDir, saveResAndFigure, regModelVersion, usefft)
    end
end
%% plot checkerboard per group
if length(subID) > 1 || plotGroup
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
    [~,~,~,Data{2},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(14,:),fh,ph(1,2),ep(4,:),flip); % Noadapt (env-driven), TM base - EMG_on(+)
    [~,~,~,Data{3},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(1,:),fh,ph(1,3),ep(6,:),flip); %  OG base - TR base = -(TR base - OG base), env switching
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
    
    resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V11/GroupResults/'];
    if saveResAndFigure    
        if not(isfolder(resDir))
            mkdir(resDir)
        end
        saveas(fh, [resDir groupID '_group_Checkerboard_ver' num2str(usefft) num2str(normalizeData) '.png'])
    end
    
    % run regression and save results
    format compact % format loose %(default)
    % not normalized first, then normalized, arugmnets order: (Data, normalizeData, isGroupData, dataId, resDir, saveResAndFigure, version, usefft) 
    runRegression_V3(Data, normalizeData, true, groupID, resDir, saveResAndFigure, regModelVersion, usefft)
    runRegression_V3(Data, true, true, groupID, resDir, saveResAndFigure, regModelVersion, usefft)
end