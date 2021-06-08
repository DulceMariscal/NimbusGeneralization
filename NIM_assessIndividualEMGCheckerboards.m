%This file will 1)load data; 
% 2)plot checkboards for all relevant epochs, save figures
% 3)plot checkboards for regression related epoch (regressors), save figures 
% 4)run regression, save the model results
% 1. load param file (assuming the needed parm files are on the
%path, or you are currently in the param file folder. 
% 2. 
%% Load data 
clear; close all; clc;

% load('/Users/samirsherlekar/Desktop/emg/Data/normalizedYoungEmgData.mat');
% load('C:\Users\dum5\Box\GeneralizationStudy Data\NormalizedFastYoungEMGData.mat')
% sub={'YL02params'};
groupID = 'NTR';
saveResAndFigure = false;

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
extremaMatrixYoung = NaN(n_subjects,n_muscles * 2,2);


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

%% plot all epochs for all relevant conditions
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


%% Regressor V2 - Update from disucssion on Tuesday MAy 4, 2021 
% Adapt VR- baseline VR
% OG base - baseline VR 
% baseline - EMG_split(-) 

usefft = 0; normalizeData = 0;
ep=defineEpochNIM_OG_UpdateV1_flipSign('nanmean');
refEpAdaptLate = defineReferenceEpoch('Task_{Switch}',ep);

refEpOGBase=defineReferenceEpoch('OGbase',ep);
refEpOGpost= defineReferenceEpoch('Post1_{Late}',ep);
refEp= defineReferenceEpoch('TMbase',ep);

%% Plot checkerboards per subject
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
    [~,~,~,Data{2},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(5,:),fh,ph(1,2),refEpOGBase,flip); %  base - OG base, env switching
    [~,~,~,Data{3},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(7,:),fh,ph(1,3),ep(6,:),flip); % Adapt SS - baseline TM, task switching (within env)
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
    
    extremaMatrixYoung(i,:,1) =  min(dataRef2);
    extremaMatrixYoung(i,:,2) =  max(dataRef2);
    if saveResAndFigure
        resDir = [scriptDir '/RegressionAnalysis/RegModelResults/'];
        if not(isfolder(resDir))
            mkdir(resDir)
        end
        saveas(fh, [resDir subID{i} '_Checkerboard_ver' num2str(usefft) num2str(normalizeData) '.png']) 
    end
end
set(gcf,'color','w');

%% plot checkerboard per group
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
if saveResAndFigure
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
%% Run regression with or without normalizing
format compact
% format loose %(default)
for normIndex = 0:1
    fprintf('\n\n')
    normalizeData = normIndex
    if normalizeData
        DataOriginal = Data;
        for i = 1:size(Data,2)
            Data{i} = Data{i}/norm(Data{i});
        end
    end

    %%% Run regression analysis V2
    tableData=table(Data{1},Data{2},Data{3},Data{4},Data{5},'VariableNames',{'Adapt', 'EnvSwitch', 'TaskSwitch', 'Trans1', 'Trans2'});
    fitTrans1NoConst=fitlm(tableData,'Trans1 ~ TaskSwitch+EnvSwitch+Adapt-1')%exclude constant
    Rsquared = fitTrans1NoConst.Rsquared

    fprintf('\n\n\n')

    fitTrans2NoConst=fitlm(tableData,'Trans2 ~ TaskSwitch+EnvSwitch+Adapt-1')%exclude constant
    Rsquared = fitTrans2NoConst.Rsquared

    if saveResAndFigure
        resDir = [scriptDir '/RegressionAnalysis/RegModelResults/'];
        if not(isfolder(resDir))
            mkdir(resDir)
        end
        if length(subID) == 1
            save([resDir, subID{1}, 'models_ver' num2str(usefft) num2str(normalizeData)], 'fitTrans1NoConst','fitTrans2NoConst')
        else
            %version convention: first digit: use first or last stride, 2nd digit:
            %use fft or not, 3rd digit: normalize or not, i.e., ver_101 = use first
            %20 strides, no fft and normalized data
            save([resDir 'AllSubjectsOrGroupResults/' groupID '_group_models_ver' num2str(usefft) num2str(normalizeData)], 'fitTrans1NoConst','fitTrans2NoConst')
        end
    end
end

%% Compute vector length of each regressors
fitTrans1NoConst.Variables