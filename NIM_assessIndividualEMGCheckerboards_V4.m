%This file will run EMG regressions and plot checkerboards.
% Version update from V3: supports processing and regression analysis using
% subjects that have 2 sessions of pos/neg short perturbations
% 
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
groupID = 'NTR_04'; % groupID to grab all subjects from the same group. If only want to grab 1 subject, specify subject ID.
saveResAndFigure = true;
plotAllEpoch = false;
plotIndSubjects = false;
plotGroup = false; %will always plot group if more than 1 subjects provided

scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 
files = dir ([scriptDir '/data/' groupID '*params.mat']);
session2_n_subjects = 0;
sub = {};
subID = {};
session2subID = {};
session2sub = {};
for i = 1:size(files,1)
    if contains(files(i).name,'Session2')
        session2_n_subjects = session2_n_subjects + 1;
        session2sub{end+1} = files(i).name;
        session2subID{end+1} = session2sub{end}(1:end-10);
    else
        sub{end+1} = files(i).name;
        subID{end+1} = sub{end}(1:end-10);
    end
end
n_subjects = size(files,1) - session2_n_subjects;
subID
session2subID

regModelVersion = 'default'
% if (contains(groupID, 'NTS'))
%     regModelVersion = 'TS'
% elseif (contains(groupID, 'NTR'))
%     regModelVersion = 'TR'
% end

%% load and prepare data. 
muscleOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'HIP'};
n_muscles = length(muscleOrder);
newLabelPrefix = defineMuscleList(muscleOrder);

normalizedTMFullAbrupt=adaptationData.createGroupAdaptData(sub);
session2Data = adaptationData.createGroupAdaptData(session2sub);

ep=defineEpochNimbusShoes('nanmean');
refEp = defineReferenceEpoch('OGNimbus',ep);
refEpLate = defineReferenceEpoch('Adaptation',ep);
epSession1 = ep;
normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,refEp);
ll=normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');
l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ll,l2);

epSession2 = defineEpochNimbusShoes_Session2('nanmean',groupID);
refEpSession2 = defineReferenceEpoch('TMBaseFast',epSession2);
session2Data = session2Data.normalizeToBaselineEpoch(newLabelPrefix,refEpSession2);
ll=session2Data.adaptData{1}.data.getLabelsThatMatch('^Norm');
l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
session2Data=session2Data.renameParams(ll,l2);

newLabelPrefix = regexprep(newLabelPrefix,'_s','s');

%% remove bad muscles
% NTS: remove sHIP and sVL
% NTR: remove fTFL
% for group data
% if contains(groupID, 'NTR')
%     badMuscleNames = {'sLGs'};
% elseif contains(groupID, 'NTS')
%     badMuscleNames = {'sHIPs','sVLs'};
% end

% for session 2 data
if strcmp(groupID, 'NTR_03')
    badMuscleNames = {'fTFLs'};
elseif strcmp(groupID, 'NTR_04')
    badMuscleNames = {'sLGs'};
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
    for session = 1:2
        if session == 1
            subjectNum = n_subjects;
            currData = normalizedTMFullAbrupt;
            ep = epSession1;
            currRefEp = refEp;
        else
            subjectNum = session2_n_subjects;
            currData = session2Data;
            ep = epSession2;
            currRefEp = refEpSession2;
        end
        for i = 1:subjectNum
            adaptDataSubject = currData.adaptData{1, i}; 

            fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
            ph=tight_subplot(1,length(ep)+1,[.03 .005],.04,.04);
            flip=true;

            adaptDataSubject.plotCheckerboards(newLabelPrefix,currRefEp,fh,ph(1,1),[],flip); %First, plot reference epoch:   
            [~,~,~,~,~]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep,fh,ph(1,2:end),currRefEp,flip);%Second, the rest:
            
            if session == 1
                adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(7,:),fh,ph(1,8),refEpLate,flip);%plot the Post1-AdaptSS epoch
            else
                adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(9:end,:),fh,ph(1,end-2:end),[],flip);%plot the Post1-AdaptSS epoch
            end

            set(ph(:,1),'CLim',[-1 1]);
            set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1.5);
            set(ph,'FontSize',8)
            pos=get(ph(1,end),'Position');
            axes(ph(1,end))
            colorbar
            set(ph(1,end),'Position',pos);
            set(gcf,'color','w');

            if (saveResAndFigure)
                resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V12/'];
                if not(isfolder(resDir))
                    mkdir(resDir)
                end
                saveas(fh, [resDir subID{i} '_AllEpochCheckerBoard_' num2str(session) '.png'])
                saveas(fh, [resDir subID{i} '_AllEpochCheckerBoard_' num2str(session)],'epsc')
            end
        end
    end
end
%% Regressor V2 - Update from disucssion on Tuesday MAy 4, 2021 
% Adapt VR- baseline VR
% OG base - baseline VR 
% baseline - EMG_split(-) 

usefft = 0; normalizeData = 0;

for splitCount = 1:2
    splitCount
    
    ep=defineEpochNIM_OG_UpdateV3('nanmean');
%         multi env and transition 1 and 2 always use this, deltaAdapt and
%         nonAdapt could be from this or the session2
    epSession2 = defineEpochNIM_OG_UpdateV4('nanmean', groupID);

    refEpAdaptLate = defineReferenceEpoch('Task_{Switch}',ep);
    refEpOGpost= defineReferenceEpoch('Post1_{Late}',ep);
    
    %% Plot checkerboards per subject
    if plotIndSubjects || length(subID) == 1
%         close all;
        for i = 1:n_subjects

            adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i}; 
            adaptDataSubjectSession2 = session2Data.adaptData{1, i}; 
            
            fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
            ph=tight_subplot(1,5,[.03 .005],.04,.04);
            flip=true;

            Data = {}; %in order: adapt, dataEnvSwitch, dataTaskSwitch, dataTrans1, dataTrans2
            %all labels should be the same, no need to save again.
            
            if splitCount == 1
                if usefft
                    [~,~,labels,Data{1},dataRef2]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(4,:),fh,ph(1,1),refEp,flip); %  EMG_split(-) - TM base VR, adaptation
                else
                    [~,~,labels,Data{1},dataRef2]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(3,:),fh,ph(1,1),refEp,flip); %  EMG_split(-) - TM base VR, adaptation
                end
                %all labels should be the same, no need to save again.
                [~,~,~,Data{2},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(14,:),fh,ph(1,2),ep(4,:),flip); % Noadapt (env-driven), TM base - EMG_on(+)
            else
                if usefft
                    [~,~,labels,Data{1},dataRef2]=adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(3,:),fh,ph(1,1),epSession2(1,:),flip); %  EMG_split(+) - TM base fast, adaptation, later will be leg swapped
                else
                    [~,~,labels,Data{1},dataRef2]=adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(2,:),fh,ph(1,1),epSession2(1,:),flip); %  EMG_split(-) - TM base fast, adaptation
                end
                [~,~,~,Data{2},~] = adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(1,:),fh,ph(1,2),epSession2(3,:),flip); % Noadapt (env-driven/within-env), - EMGon(+) = TM base - EMG_on(+)
            end
            
            [~,~,~,Data{3},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(1,:),fh,ph(1,3),ep(6,:),flip); %  -(TR base - OG base) = OG base - TR base, env switching
            [~,~,~,Data{4},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(8,:),fh,ph(1,4),refEpAdaptLate,flip); %OGafter - Adaptation_{SS} , transition 1
            [~,~,~,Data{5},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(11,:),fh,ph(1,5),refEpOGpost,flip); %Nimbus post early - OG post late, transition 2
        
            set(ph(:,1),'CLim',[-1 1]);
            set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1.5);
            set(ph,'FontSize',8)
            pos=get(ph(1,end),'Position');
            axes(ph(1,end))
            colorbar
            set(ph(1,end),'Position',pos);
            set(gcf,'color','w');

            resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V12/'];
            if saveResAndFigure
                if not(isfolder(resDir))
                    mkdir(resDir)
                end
%                 saveas(fh, [resDir subID{i} '_Checkerboard_ver' num2str(usefft) num2str(normalizeData) regModelVersion '_split_' num2str(splitCount) '.png']) 
%                 saveas(fh, [resDir subID{i} '_Checkerboard_ver' num2str(usefft) num2str(normalizeData) regModelVersion '_split_' num2str(splitCount)],'epsc') 
            end

            % run regression and save results
            format compact % format loose %(default)
            % not normalized first, then normalized, arugmnets order: (Data, normalizeData, isGroupData, dataId, resDir, saveResAndFigure, version, usefft) 
            runRegression_V3(Data, false, false, [subID{i} regModelVersion '_split' num2str(splitCount)], resDir, saveResAndFigure, regModelVersion, usefft)
            runRegression_V3(Data, true, false, [subID{i} regModelVersion '_split' num2str(splitCount)], resDir, saveResAndFigure, regModelVersion, usefft)
        end
    end
    %% plot checkerboard per group
    if length(subID) > 1 || plotGroup
        fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
        ph=tight_subplot(1,5,[.03 .005],.04,.04);
        flip=true;

        Data = {}; %in order: adapt, dataEnvSwitch, dataTaskSwitch, dataTrans1, dataTrans2
        if splitCount == 1
            if usefft
                [~,~,labels,Data{1},dataRef2]=normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(4,:),fh,ph(1,1),refEp,flip); %  EMG_split(-) - TM base VR, adaptation
            else
                [~,~,labels,Data{1},dataRef2]=normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(3,:),fh,ph(1,1),refEp,flip); %  EMG_split(-) - TM base VR, adaptation
            end
            %all labels should be the same, no need to save again.
            [~,~,~,Data{2},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(14,:),fh,ph(1,2),ep(4,:),flip); % Noadapt (env-driven), TM base - EMG_on(+)
        else
            if usefft
                [~,~,labels,Data{1},dataRef2]=session2Data.plotCheckerboards(newLabelPrefix,epSession2(3,:),fh,ph(1,1),epSession2(1,:),flip); %  EMG_split(+) - TM base fast, adaptation, later will be leg swapped
            else
                [~,~,labels,Data{1},dataRef2]=session2Data.plotCheckerboards(newLabelPrefix,epSession2(2,:),fh,ph(1,1),epSession2(1,:),flip); %  EMG_split(-) - TM base fast, adaptation
            end
            [~,~,~,Data{2},~] = session2Data.plotCheckerboards(newLabelPrefix,epSession2(1,:),fh,ph(1,2),epSession2(3,:),flip); % Noadapt (env-driven/within-env), - EMGon(+) = TM base - EMG_on(+)
        end
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

        resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V12/GroupResults/'];
        if saveResAndFigure    
            if not(isfolder(resDir))
                mkdir(resDir)
            end
            saveas(fh, [resDir groupID '_group_Checkerboard_ver' num2str(usefft) num2str(normalizeData) regModelVersion '_split_' num2str(splitCount) '.png'])
            saveas(fh, [resDir groupID '_group_Checkerboard_ver' num2str(usefft) num2str(normalizeData) regModelVersion '_split_' num2str(splitCount)], 'epsc')
        end

        % run regression and save results
        format compact % format loose %(default)
        % not normalized first, then normalized, arugmnets order: (Data, normalizeData, isGroupData, dataId, resDir, saveResAndFigure, version, usefft) 
        runRegression_V3(Data, normalizeData, true, [groupID regModelVersion '_split' num2str(splitCount)], resDir, saveResAndFigure, regModelVersion, usefft)
        runRegression_V3(Data, true, true, [groupID regModelVersion '_split' num2str(splitCount)], resDir, saveResAndFigure, regModelVersion, usefft)
    end
end

%% Compare shoe vs TM perturbation
% Compare on, off, pos and neg
%         multi env and transition 1 and 2 always use this, deltaAdapt and
%         nonAdapt could be from this or the session2
epSession2 = defineEpochNIM_OG_UpdateV4('nanmean', groupID);
ep=defineEpochNIM_OG_UpdateV3('nanmean');
format compact

if plotIndSubjects || length(subID) == 1
%         close all;
    for i = 1:n_subjects
        adaptDataSubjectSession2 = session2Data.adaptData{1, i}; 

        fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
        ph=tight_subplot(1,14,[.03 .005],.04,.04);
        flip=true;

        Data = {}; 
%         -On Pos (TMtied - PosShortEarly)
        [~,~,labels,Data{1},dataRef2]=adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(1,:),fh,ph(1,1),epSession2(3,:),flip); %  EMG_split(+) - TM base fast, adaptation, later will be leg swapped
        [~,~,~,Data{2},~]=adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(5,:),fh,ph(1,2),epSession2(4,:),flip); %  EMG_split(+) - TM base fast, adaptation, later will be leg swapped
        
%         - Off Pos (PosShortLate - OG)
        [~,~,~,Data{3},~]=adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(6,:),fh,ph(1,3),epSession2(9,:),flip); %  EMG_split(+) - TM base fast, adaptation, later will be leg swapped
        [~,~,~,Data{4},~]=adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(7,:),fh,ph(1,4),epSession2(8,:),flip); %  EMG_split(+) - TM base fast, adaptation, later will be leg swapped

%         -OnNeg (TMtied - NegShortEarly)
        [~,~,~,Data{5},~]=adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(13,:),fh,ph(1,5),epSession2(2,:),flip); %  EMG_split(+) - TM base fast, adaptation, later will be leg swapped
        [~,~,~,Data{6},~]=adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(5,:),fh,ph(1,6),epSession2(4,:),flip); %  EMG_split(+) - TM base fast, adaptation, later will be leg swapped
        
%         - Off Neg (NegShortLate - OG)
        [~,~,~,Data{7},~]=adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(10,:),fh,ph(1,7),epSession2(12,:),flip); %  EMG_split(+) - TM base fast, adaptation, later will be leg swapped
        [~,~,~,Data{8},~]=adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(7,:),fh,ph(1,8),epSession2(8,:),flip); %  EMG_split(+) - TM base fast, adaptation, later will be leg swapped


        adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(5,:),fh,ph(1,9),[],flip); 
        title('TMfast')
        adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(1,:),fh,ph(1,10),[],flip); 
        title('TMTied2')
        adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(13,:),fh,ph(1,11),[],flip);
        title('TMTied3')
        
        adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(8,:),fh,ph(1,12),[],flip); 
        title('OG1')
        adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(9,:),fh,ph(1,13),[],flip); 
        title('OG2')
        adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(12,:),fh,ph(1,14),[],flip);
        title('OG3')
        
        set(ph(:,1),'CLim',[-1 1]);
        set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1.5);
        set(ph,'FontSize',8)
        pos=get(ph(1,end),'Position');
        axes(ph(1,end))
        colorbar
        set(ph(1,end),'Position',pos);
        set(gcf,'color','w');

        resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V12/'];
        if saveResAndFigure
            if not(isfolder(resDir))
                mkdir(resDir)
            end
            saveas(fh, [resDir subID{i} '_ShoeVsTM' '.png']) 
            saveas(fh, [resDir subID{i} '_ShoeVsTM'],'epsc') 
        end

        % run regression and save results
        format compact % format loose %(default)
        % not normalized first, then normalized, arugmnets order: (Data, normalizeData, isGroupData, dataId, resDir, saveResAndFigure, version, usefft) 
        Data{6} = fftshift(Data{6},1);
        Data{8} = fftshift(Data{8},1);    
        
        dataorder = {'-OnPos','-OffPos','-OnNeg','-OffNeg'};
        corr_coef={};
        cosine_value={};
        for j = 1:4
            comparison = dataorder{j}
            corr_coef{j} = corrcoef(Data{j*2-1},Data{j*2});
            cosine_value{j} = cosine(Data{j*2-1}(:),Data{j*2}(:));
%             corr_coef_normalized = corrcoef(Data{j*2-1}(:)/norm(Data{j*2-1}(:)),Data{j*2}(:)/norm(Data{j*2}(:)))
        end
        clc;
        dataorder
        celldisp(corr_coef)
        cosine_value
        if saveResAndFigure
            save([resDir subID{i} '_ShoeVsTM_Cos_CorrCoef'],'dataorder','corr_coef','cosine_value')
        end
    end
end

%% Compare Off perturbation to OG vs  off pertubation + multiEnvSwitch
% Compare TRSplitLate - OGPostEarly ~ (TRBase - OGBase) + (TRSplitLate - TRPostEarly)
epSession2 = defineEpochNIM_OG_UpdateV4('nanmean', groupID);
ep=defineEpochNIM_OG_UpdateV3('nanmean');

%         close all;
for i = 1:n_subjects
    adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i}; 
    adaptDataSubjectSession2 = session2Data.adaptData{1, i}; 

    fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
    ph=tight_subplot(1,3,[.03 .005],.04,.04);
    flip=true;

    Data = {}; 
    %all labels should be the same, no need to save again.
    %  OGPost - TRSplitLate
    [~,~,labels,Data{1},dataRef2]=adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(8,:),fh,ph(1,1),epSession2(7,:),flip); %  EMG_split(+) - TM base fast, adaptation, later will be leg swapped
    title('OGPost - ShoeSplitLate')
    % OGBase - TRBase
    [~,~,~,Data{2},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(1,:),fh,ph(1,2),ep(6,:),flip); %  -(TR base - OG base) = OG base - TR base, env switching
    title('OGBaseLate - TRBaseLate')
    % TRBase - TRSplitEarly
    [~,~,~,Data{3},~]=adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(1,:),fh,ph(1,3),epSession2(3,:),flip);
    title('TMBaseLate - TMSplitEarly')

    set(ph(:,1),'CLim',[-1 1]);
    set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1.5);
    set(ph,'FontSize',8)
    pos=get(ph(1,end),'Position');
    axes(ph(1,end))
    colorbar
    set(ph(1,end),'Position',pos);
    set(gcf,'color','w');

    resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V12/'];
    if saveResAndFigure
        if not(isfolder(resDir))
            mkdir(resDir)
        end
        saveas(fh, [resDir subID{i} '_ShoeOffLinear' '.png']) 
%             saveas(fh, [resDir subID{i} '_ShoeOffLinear'],'epsc') 
    end

    % run regression and save results
    format compact % format loose %(default)
    YvsTerm1Correlation = corrcoef(Data{1},Data{2})
    YvsTerm2Correlation = corrcoef(Data{1},Data{3})
    corr_coef={YvsTerm1Correlation, YvsTerm2Correlation};
    
    for j = 1:size(Data,2)
        Data{j} = reshape(Data{j}, [],1); %make it a column vector
    end
    YvsTerm1Cos = cosine(Data{1},Data{2})
    YvsTerm2Cos = cosine(Data{1},Data{3})
    cosine_values={YvsTerm1Cos, YvsTerm2Cos};
    
    %%% Run regression to see if the LHS and RHS are equal
    tableData=table(Data{1},Data{2},Data{3},'VariableNames',{'OGToTRSplit', 'OGToTR', 'TRToSplit'});
    linearityAssessmentModel=fitlm(tableData, 'OGToTRSplit~OGToTR+TRToSplit-1')%exclude constant
    Rsquared = linearityAssessmentModel.Rsquared

    if saveResAndFigure
        save([resDir subID{i} '_ShoeOffLinear_CorrCoef_Model'],'corr_coef','cosine_values','linearityAssessmentModel')
    end
end
