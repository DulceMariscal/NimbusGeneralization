%This file will run EMG regressions and plot checkerboards.
% Version update from V4: cleaner version, elimanting multiple regression
% optons and focusing on the three regressors model
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

%sections:
%1)load data
%2) load and prepare data
%3) remove bad muscles
%4)Regressor analysis: Focus on the tree regressors model
%% Load data
clear; close all; clc;


% set script parameters, SHOULD CHANGE/CHECK THIS EVERY TIME.
groupID = 'NTR'; % groupID to grab all subjects from the same group. If only want to grab 1 subject, specify subject ID.
saveResAndFigure = false;
plotAllEpoch = true;
plotIndSubjects = false;
plotGroup = true; %will always plot group if more than 1 subjects provided

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


if (contains(groupID, 'NTS'))
    Testing = true; 
else
    Testing = false;
end

regModelVersion = 'default';


%% load and prepare data.
muscleOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'HIP'};
n_muscles = length(muscleOrder);
newLabelPrefix = defineMuscleList(muscleOrder);
totalSessions = 1; %used later to determine what epochs to use for plotting

if Testing
    normalizedTMFullAbrupt=adaptationData.createGroupAdaptData(sub);
    epLong=defineEpochNimbusShoes_longProtocol('nanmean'); %save the full epoch in a separate name
    ep = epLong;
    if ~isempty(session2subID)
        session2Data= adaptationData.createGroupAdaptData(session2sub);
        epSession2 = defineEpochNimbusShoesTesting_Session2('nanmean');
        refEpSession2 = defineReferenceEpoch('OGBase',epSession2);
        session2Data =session2Data.removeBadStrides;
        session2Data = session2Data.normalizeToBaselineEpoch(newLabelPrefix,refEpSession2);
        ll=session2Data.adaptData{1}.data.getLabelsThatMatch('^Norm');
        l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
        session2Data=session2Data.renameParams(ll,l2);
        totalSessions = 1;
    end
else
    normalizedTMFullAbrupt=adaptationData.createGroupAdaptData(sub);
    ep=defineEpochNimbusShoes('nanmean');
    epSession1 = ep;
    if ~isempty(session2subID)
        session2Data= adaptationData.createGroupAdaptData(session2sub);
        epSession2 = defineEpochNimbusShoes_Session2('nanmean',groupID);
        refEpSession2 = defineReferenceEpoch('OGBase',epSession2);
        session2Data =session2Data.removeBadStrides;
        session2Data = session2Data.normalizeToBaselineEpoch(newLabelPrefix,refEpSession2);
        ll=session2Data.adaptData{1}.data.getLabelsThatMatch('^Norm');
        l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
        session2Data=session2Data.renameParams(ll,l2);
        totalSessions = 1;
    end
end
%define some common reference epochs

refEpOG = defineReferenceEpoch('OGBase',ep);

normalizedTMFullAbrupt=normalizedTMFullAbrupt.removeBadStrides;
normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,refEpOG);
ll=normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');
l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ll,l2);
newLabelPrefix = regexprep(newLabelPrefix,'_s','s');

%% remove bad muscles
% NTS: remove sHIP and sVL
% NTR: remove fTFL
% for session 2 data
if strcmp(groupID, 'NTR_03')
    badMuscleNames = {'fRFs','sRFs'};
elseif strcmp(groupID, 'NTR_04')
    badMuscleNames = {'sLGs'};
elseif strcmp(groupID, 'NTR')
    badMuscleNames = {'sLGs','fTFLs','fSEMTs','sSEMTs'};
    %      badMuscleNames = {'sLGs','fTFLs','fLGs','sTFLs'};
elseif  strcmp(groupID, 'NTR_05')
    badMuscleNames = {'fSEMTs','sSEMTs'};
    % elseif  strcmp(groupID, 'NTS')
    %     badMuscleNames = {'fRFs','sRFs','sVLs','fVLs','sHIPs','fHIPs'};
elseif  strcmp(groupID, 'NTS_06')
    badMuscleNames = {'sHIPs','fHIPs'};
elseif  strcmp(groupID, 'NTS_01')
    badMuscleNames = {'sHIPs','fHIPs'};
elseif  strcmp(groupID, 'NTS_05')
    badMuscleNames = {'sRFs'};
end

if exist('badMuscleNames','var') %check if badMuscleNames is defined, if so update the labels list.
    badMuscleIdx=[];
    for bm = badMuscleNames
        badMuscleIdx = [badMuscleIdx, find(ismember(newLabelPrefix,bm))];
    end
    newLabelPrefix = newLabelPrefix(setdiff(1:end, badMuscleIdx))
end



%% 4)Regressor analysis: Focus on the tree regressors model


clc
regModelVersion = 'default'
usefft = 0; normalizeData = 0;
splitCount = 1
% Testing=1

if Testing
    ep = epLong;
    if ~isempty(session2subID)
        epSession2;
    end
    
    OGbase=  defineReferenceEpoch('OGBase',ep);
    EnvBase = defineReferenceEpoch('OGNimbus',ep);
    
    AdaptLate = defineReferenceEpoch('Adaptation',ep);
    Post1Late= defineReferenceEpoch('Post1_{Late}',ep);
    Post1Early= defineReferenceEpoch('Post1_{Early}',ep);
    Post2Early=defineReferenceEpoch('Post2_{Early}',ep);
    
    TMbeforePos= defineReferenceEpoch('TMfast2',epSession2);
    PosShort=defineReferenceEpoch('PostShort',epSession2);
    OGpostPosEarly=defineReferenceEpoch('OGAfterPost',epSession2);
    
    NegShort= defineReferenceEpoch('NegShort',epSession2);
    TMbeforeNeg = defineReferenceEpoch('TMslow2',epSession2);
    
else
    ep=defineEpochNIM_OG_UpdateV3('nanmean');
    
    if ~isempty(session2subID)
        epSession2 = defineEpochNIM_NTR_Session2('nanmean', groupID);
    end
    
    OGbase=  defineReferenceEpoch('OGBase',ep);
    EnvBase = defineReferenceEpoch('NIMBase',ep);
    
    AdaptLate = defineReferenceEpoch('Adaptation',ep);
    Post1Late= defineReferenceEpoch('Post1_{Late}',ep);
    Post1Early= defineReferenceEpoch('Post1_{Early}',ep);
    Post2Early=defineReferenceEpoch('Post2_{Early}',ep);
    
    
    TMbeforePos= defineReferenceEpoch('TM tied 2',epSession2);
    PosShort=defineReferenceEpoch('Pos short',epSession2);
    OGpostPosEarly=defineReferenceEpoch('OG 2',epSession2);
    
    TMbeforeNeg = defineReferenceEpoch('TM tied 3',epSession2);
    NegShort=defineReferenceEpoch('Neg short',epSession2);
    
    
end

%%
if plotIndSubjects
    for i = 1:n_subjects
        
        
        flip = 1;
        [Data,regressorNames,fh]=RegressionsGeneralization(newLabelPrefix,normalizedTMFullAbrupt,session2Data,1,0,NegShort,TMbeforeNeg,PosShort,TMbeforePos,...
            AdaptLate,Post1Early,Post1Late,Post2Early, OGpostPosEarly, OGbase, EnvBase, i,flip);
        
        nw=datestr(now,'yy-mm-dd');
        resDir = [scriptDir '/RegressionAnalysis/RegModelResults_', nw ,'/IndvResults/'];
        
        
        if saveResAndFigure
            if not(isfolder(resDir))
                mkdir(resDir)
            end
            saveas(fh, [resDir subID{i} '_Checkerboard_Asym_ver' num2str(usefft) num2str(normalizeData) regModelVersion '_split_' num2str(splitCount) 'flip_' num2str(flip) '.png'])
            saveas(fh, [resDir subID{i} '_Checkerboard_ver' num2str(usefft) num2str(normalizeData) regModelVersion '_split_' num2str(splitCount)],'epsc')
        end
        
        %                 if flip == 2 %asym plot, do cosine measures
        asymCos = findCosBtwAsymOfEpochs(Data, size(newLabelPrefix,2),regressorNames)
        %                 else
        % run regression and save results
        format compact % format loose %(default)
        % not normalized first, then normalized, arugmnets order: (Data, normalizeData, isGroupData, dataId, resDir, saveResAndFigure, version, usefft)
        runRegression_V3(Data, false, false, [subID{i} regModelVersion '_split' num2str(splitCount) 'flip_' num2str(flip)], resDir, saveResAndFigure, regModelVersion, usefft, regressorNames)
        runRegression_V3(Data, true, false, [subID{i} regModelVersion '_split' num2str(splitCount) 'flip_' num2str(flip)], resDir, saveResAndFigure, regModelVersion, usefft, regressorNames)
        %                 end
        
    end
end

%%
% plot checkerboard per group
splitCount = 1
if ~length(subID) > 1 || plotGroup
    
    flip = [1];
    
    Data = {}; %in order: {'Adapt','WithinContextSwitch','MultiContextSwitch','Trans1','Trans2'};
    %                         [~,~,labels,dataE{1},dataRef{1}]=normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep,fh,ph(1,2:end),refEp,flip);%Second, the rest:
    
    [Data,regressorNames]=RegressionsGeneralization(newLabelPrefix,normalizedTMFullAbrupt,session2Data,0,1,NegShort,TMbeforeNeg,PosShort,TMbeforePos,...
        AdaptLate,Post1Early,Post1Late,Post2Early, OGpostPosEarly, OGbase, EnvBase,[],[],[],flip);
    
    nw=datestr(now,'yy-mm-dd');
    resDir = [scriptDir '/RegressionAnalysis/RegModelResults_',nw ,'/GroupResults/'];
    if saveResAndFigure
        if not(isfolder(resDir))
            mkdir(resDir)
        end
        saveas(fh, [resDir groupID '_group_Checkerboard_ver' num2str(usefft) num2str(normalizeData) regModelVersion '_split_' num2str(splitCount) 'asym_' num2str(flip) '.png'])
        %             saveas(fh, [resDir groupID '_group_Checkerboard_ver' num2str(usefft) num2str(normalizeData) regModelVersion '_split_' num2str(splitCount)], 'epsc')
    end
    
    if flip ~=2 %only run regression for full data without flipping or asymmetry change.
        % run regression and save results
        format compact % format loose %(default)
        % not normalized first, then normalized, arugmnets order: (Data, normalizeData, isGroupData, dataId, resDir, saveResAndFigure, version, usefft)
        runRegression_V3(Data, normalizeData, true, [groupID regModelVersion '_split' num2str(splitCount) 'asym_' num2str(flip)], resDir, saveResAndFigure, regModelVersion, usefft)
        runRegression_V3(Data, true, true, [groupID regModelVersion '_split' num2str(splitCount) 'asym_' num2str(flip)], resDir, saveResAndFigure, regModelVersion, usefft)
    else%asym plot, do cosine measures
        asymCos = findCosBtwAsymOfEpochs(Data, size(newLabelPrefix,2))
    end
    
end
%% plot all epochs for all relevant conditions
if plotAllEpoch
    for session = 1:totalSessions
        if Testing
            subjectNum = n_subjects;
            currData = normalizedTMFullAbrupt;
            currRefEp = refEpTR;
            %             currRefEp = [];
            ep = epLong;
        else
            if session == 1
                subjectNum = n_subjects;
                currData = normalizedTMFullAbrupt;
                ep = epSession1;
                currRefEp = refEpTR;
                currRefEp = [];
            else
                subjectNum = session2_n_subjects;
                currData = session2Data;
                ep = epSession2;
                currRefEp = refEpSession2;
                currRefEp = [];
            end
        end
        for i = 1:subjectNum
            adaptDataSubject = currData.adaptData{1, i};
            fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
            ph=tight_subplot(1,length(ep)+1,[.03 .005],.04,.04);
            flip=true;
            
            adaptDataSubject.plotCheckerboards(newLabelPrefix,currRefEp,fh,ph(1,1),[],flip); %First, plot reference epoch:
            currRefEp = [];
            [~,~,~,~,~]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep,fh,ph(1,2:end),currRefEp,flip);%Second, the rest:
            
            set(ph(:,1),'CLim',[-1 1]*1.5);
            set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1.5);
            set(ph,'FontSize',8)
            pos=get(ph(1,end),'Position');
            axes(ph(1,end))
            colorbar
            set(ph(1,end),'Position',pos);
            set(gcf,'color','w');
            
            if (saveResAndFigure)
                resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V14/'];
                if not(isfolder(resDir))
                    mkdir(resDir)
                end
                saveas(fh, [resDir subID{i} '_AllEpochCheckerBoard_' num2str(session) '.png'])
                                saveas(fh, [resDir subID{i} '_AllEpochCheckerBoard_' num2str(session)],'epsc')
            end
        end
    end
end

%% plot subsets of epochs: AE with context specific baseline correction
%AE only pertains to session 1 and long protocols.

if Testing
    subjectNum = n_subjects;
    ep = epLong;
else
    subjectNum = n_subjects;
    ep = epSession1;
end
post1ep = ep(strcmp(ep.Properties.ObsNames,'Post1_{Early}'),:);
post2ep = ep(strcmp(ep.Properties.ObsNames,'Post2_{Early}'),:);
post1lateep = ep(strcmp(ep.Properties.ObsNames,'Post1_{Late}'),:);
post2lateep = ep(strcmp(ep.Properties.ObsNames,'Post2_{Late}'),:);

if (contains(groupID, 'NTS'))
    refEpPos1 = defineReferenceEpoch('OGBase',ep);
    refEpPos2 = defineReferenceEpoch('OGNimbus',ep);
elseif (contains(groupID, 'NTR'))
    refEpPos1 = defineReferenceEpoch('OGNimbus',ep);
    refEpPos2= defineReferenceEpoch('OGBase',ep);
end
 

for flip = [1]%,2] %2 legs separate first (flip = 1) and then asymmetry (flip = 2)
    %     the flip asymmetry plots average of summation and the average of
    %     asymmetry.
    for i = 1:subjectNum
        if plotGroup
            adaptDataSubject = normalizedTMFullAbrupt;
            figureSaveId = groupID;
        else
            adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i};
            figureSaveId = subID{i};
        end
        
        fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
        ph=tight_subplot(1,9,[.03 .005],.04,.04);
        
        
        % plot after effects only
        adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpPos1,fh,ph(1,1),[],flip); %plot OG base
        adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpPos2,fh,ph(1,2),[],flip); %plot OG base with shoe
        
        adaptDataSubject.plotCheckerboards(newLabelPrefix,post1ep,fh,ph(1,3),rrefEpPos1,flip); %post1 is OG
        adaptDataSubject.plotCheckerboards(newLabelPrefix,post2ep,fh,ph(1,4),refEpPos2,flip); %post2 is with Nimbus(TR)
        adaptDataSubject.plotCheckerboards(newLabelPrefix,post1lateep,fh,ph(1,5),refEpPos1,flip);
        adaptDataSubject.plotCheckerboards(newLabelPrefix,post2lateep,fh,ph(1,6),refEpPos2,flip);
            
        adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(7,:),fh,ph(1,7),ep(6,:),flip);
        title('trans1')
        adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(10,:),fh,ph(1,8),ep(9,:),flip);
        title('trans2')
        adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpOG,fh,ph(1,9),refEpTR,flip);
        title('OG-TRbase')
        
        set(ph(:,1),'CLim',[-1 1]);
        set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*0.5);
        set(ph,'FontSize',8)
        pos=get(ph(1,end),'Position');
        axes(ph(1,end))
        colorbar
        set(ph(1,end),'Position',pos);
        set(gcf,'color','w');
        
       
    end
end
%% EMG aftereffects

refEpPost1Early= defineReferenceEpoch('Post1_{Early}',ep);
if contains(groupID,'NTR')
    refEp= defineReferenceEpoch('OGNimbus',ep); %fast tied 1 if short split 1, slow tied if 2nd split
elseif contains(groupID,'NTS')
    refEp= defineReferenceEpoch('OGBase',ep);
end
fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
ph=tight_subplot(1,n_subjects+1,[.03 .005],.04,.04);
flip = 1;

nw=datestr(now,'yy-mm-dd');

if plotIndSubjects
    for i = 1:n_subjects
        adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i};
        load([scriptDir '/RegressionAnalysis/RegModelResults_',nw ,'/IndvResults/',subID{i} 'default_split1flip_1models_ver00.mat'])
        [~,~,~,Data{i},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpPost1Early,fh,ph(1,i),refEp,flip); %|EMG_earlyPost1 -  EMG_Baseline
        vec_norm = norm(Data{i});
        if contains(groupID,'NTR')
            title({[adaptDataSubject.subData.ID] ['Norm=', num2str(norm(reshape(Data{i},[],1))), '| \beta_{adapt}=', num2str(fitTrans1NoConst.Coefficients.Estimate(1))]});
        else
            title({[adaptDataSubject.subData.ID] ['Norm=', num2str(norm(reshape(Data{i},[],1))),'| \beta_{adapt}=', num2str(fitTrans1NoConst.Coefficients.Estimate(1))]});
        end
        
    end
    summFlag='nanmedian';
    [~,~,~,Data{i+1},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,refEpPost1Early,fh,ph(1,n_subjects+1),refEp,flip,summFlag); %|EMG_earlyPost1 -  EMG_Baseline
    summFlag='nanmedian';
    eval(['fun=@(x) ' summFlag '(x,4);']);
    Data{i+1}=fun(Data{i+1});
    vec_norm = norm(Data{i+1});
    load([scriptDir '/RegressionAnalysis/RegModelResults_',nw ,'/GroupResults/', groupID,'default_split1asym_1_group_models_ver00.mat'])
    if contains(groupID,'NTR')
        title({['Group'] ['Norm=', num2str(norm(reshape(Data{i+1},[],1))),'| \beta_{adapt}=', num2str(fitTrans1NoConst.Coefficients.Estimate(1))]});
    else
        title({['Group'] ['Norm=', num2str(norm(reshape(Data{i+1},[],1))),'| \beta_{adapt}=', num2str(fitTrans1NoConst.Coefficients.Estimate(1))]});
    end
end
set(ph(:,1),'CLim',[-1 1]*1);
set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1);
set(ph,'FontSize',8)
pos=get(ph(1,end),'Position');
axes(ph(1,end))
colorbar
set(ph(1,end),'Position',pos);
set(gcf,'color','w');

%% Comparing baseline late to Post 1 and Post 2 late

OGbase=defineReferenceEpoch('OGBase',ep);
TMbase= defineReferenceEpoch('OGNimbus',ep);
Pos1_Late=defineReferenceEpoch('Post1_{Late}',ep);
Pos2_Late=defineReferenceEpoch('Post2_{Late}',ep);

EpochsOfInteres={OGbase,TMbase,Pos1_Late,Pos2_Late};


if plotIndSubjects
    plotEpochsPlusNorm(EpochsOfInteres,normalizedTMFullAbrupt,newLabelPrefix,1,0)
end

if plotGroup
    plotEpochsPlusNorm(EpochsOfInteres,normalizedTMFullAbrupt,newLabelPrefix,0,1)
    
end
