%This file will run EMG regressions and plot checkerboards.
% Version update from V3: focus on subjects that performed 2 sets of
% pos/neg short perturbations
% 
% 1)load data; assuming the data is saved under currentDir/data/
% 2)plot checkboards for all relevant epochs, save figures, can be turned
% off by setting plotAllEpoch to false
% 3)plot checkboards for regression related epoch (regressors), save figures, 
%run regression and save the model results.
% - can plot and run regression for both indidual subjects or group subjects (set by plotGroup flag or when there are more than 1 subjects provided),
% turn off individual subjects plotting by setting to false
% The results are saved under
% currentDir/RegressionAnalysis/RegModelResults_V##. If there are code
% changes that's worth a version update, search for _V## and then update
% the version number to avoid overwrite.

%% Load data and Plot checkerboard for all conditions.
clear; close all; clc;

%temporary rename conditions for ctr 02 to make OG1 the OG base 
% changeCondName('CTR_05','TM fast','TM tied 1')
% changeCondName('CTR_02_2','TM tied 4','TM slow')

% set script parameters, SHOULD CHANGE/CHECK THIS EVERY TIME.
groupID = 'CTS_03';
saveResAndFigure = true;
plotAllEpoch = true;
plotIndSubjects = true;
plotGroup = false;

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

regModelVersion =  'default'; %'default'
if (contains(groupID, 'CTS') || contains(groupID, 'VROG'))
    regModelVersion = 'TS'
elseif (contains(groupID, 'CTR'))
    regModelVersion = 'TR'
end

%% load and prep data
normalizedTMFullAbrupt=adaptationData.createGroupAdaptData(sub);
normalizedTMFullAbrupt.removeBadStrides;

ss =normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');

% ss =TMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm'); %Dulce 
s2 = regexprep(ss,'^Norm','dsjrs');
normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ss,s2);
% normalizedTMFullAbrupt=studyData.TMFullAbrupt.renameParams(ss,s2);

% muscleOrder={'TA','MG','SEMT','VL','RF'};
muscleOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'HIP'};

n_muscles = length(muscleOrder);

n_subjects = length(subID);

ep=defineEpochVR_OG_With2ShortSplit('nanmean');
% refEp = defineReferenceEpoch('TM tied 1(fast50)',ep);
refEp = defineReferenceEpoch('TRbase',ep);
refEpLate = defineReferenceEpoch('Adaptation',ep);
refEpSlow = defineReferenceEpoch('TM tied 4(slow)',ep);

newLabelPrefix = defineMuscleList(muscleOrder);

% normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,ep(1,:));
normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,refEp);
normalizedTMFullAbrupt.removeBadStrides;

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
        ph=tight_subplot(1,length(ep)+2,[.03 .005],.04,.04);
        flip=true;

        adaptDataSubject.plotCheckerboards(newLabelPrefix,refEp,fh,ph(1,1),[],flip); %plot TM tied 1 reference
        adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(3,:),fh,ph(1,2),[],flip); %plot TR base reference
        
        adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(1:8,:),fh,ph(1,3:10),refEp,flip);%plot all epochs normalized by the fast baseline
        adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(9,:),fh,ph(1,11),refEpLate,flip);%plot the early Post - late Ada block
        adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(10:11,:),fh,ph(1,12:13),refEp,flip);%plot all remaining epochs normalized by the fast baseline
        
        adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(12:13,:),fh,ph(1,14:15),refEpSlow,flip);%plot all epochs normalized by the slow baseline (2nd short split)
        adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpSlow,fh,ph(1,16),[],flip); %plot TM tied 4 (slow base close to neg/pos short 2)
        adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(14,:),fh,ph(1,17),[],flip); %plot TM base slow from the beginning
        

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
            resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V14/'];
            if not(isfolder(resDir))
                mkdir(resDir)
            end
            saveas(fh, [resDir subID{i} '_AllEpochCheckerBoard.png'])
            saveas(fh, [resDir subID{i} '_AllEpochCheckerBoard'],'epsc') 
        end
    end
end

%% plot subsets of epochs: AE with context specific baseline correction
%AE only pertains to session 1 and long protocols.
refEpOG = defineReferenceEpoch('OGbase',ep);
refEpTR = defineReferenceEpoch('TRbase',ep);
post1ep = ep(strcmp(ep.Properties.ObsNames,'Post1_{Early}'),:);
post2ep = ep(strcmp(ep.Properties.ObsNames,'Post2_{Early}'),:);

post1lateep = ep(strcmp(ep.Properties.ObsNames,'Post1_{Late}'),:);
post2lateep = ep(strcmp(ep.Properties.ObsNames,'Post2_{Late}'),:);
for flip = [1,2] %2 legs separate first (flip = 1) and then asymmetry (flip = 2)
%     the flip asymmetry plots average of summation and the average of
%     asymmetry.
    for i = 1:n_subjects
        if plotGroup
            adaptDataSubject = normalizedTMFullAbrupt;
            figureSaveId = groupID;
        else
            adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i}; 
            figureSaveId = subID{i};
        end

        fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
        ph=tight_subplot(1,6,[.03 .005],.04,.04);

        % plot after effects only
        adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpOG,fh,ph(1,1),[],flip); %plot OG base
        adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpTR,fh,ph(1,2),[],flip); %plot OG base with shoe

%         if (contains(groupID, 'TS'))%correct post 1 with OG no nimbus, post 2 with OG with nimbus, i.e.,TR
%             adaptDataSubject.plotCheckerboards(newLabelPrefix,post1ep,fh,ph(1,3),refEpOG,flip); %post1 is OG
%             adaptDataSubject.plotCheckerboards(newLabelPrefix,post2ep,fh,ph(1,4),refEpTR,flip); %post2 is with Nimbus(TR)
%         elseif (contains(groupID, 'TR')) %correct post 1 with TR(nimbus), post 2 with OG (No nimbus)
%             adaptDataSubject.plotCheckerboards(newLabelPrefix,post1ep,fh,ph(1,3),refEpTR,flip); 
%             adaptDataSubject.plotCheckerboards(newLabelPrefix,post2ep,fh,ph(1,4),refEpOG,flip); 
%         end
        
        adaptDataSubject.plotCheckerboards(newLabelPrefix,post1ep,fh,ph(1,3),[],flip); 
        adaptDataSubject.plotCheckerboards(newLabelPrefix,post2ep,fh,ph(1,4),[],flip); 
        adaptDataSubject.plotCheckerboards(newLabelPrefix,post1lateep,fh,ph(1,5),[],flip); 
        adaptDataSubject.plotCheckerboards(newLabelPrefix,post2lateep,fh,ph(1,6),[],flip); 
%         adaptDataSubject.plotCheckerboards(newLabelPrefix,post1ep,fh,ph(1,7),ep(4,:),flip); 
%         title('trans2');
%         adaptDataSubject.plotCheckerboards(newLabelPrefix,post2ep,fh,ph(1,8),post1lateep,flip); 
%         title('trans2');
%         adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpOG,fh,ph(1,9),refEpTR,flip); 
%         title('OG-TRbase');
                
        set(ph(:,1),'CLim',[-1 1]);
        set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*0.5);
        set(ph,'FontSize',8)
        pos=get(ph(1,end),'Position');
        axes(ph(1,end))
        colorbar
        set(ph(1,end),'Position',pos);
        set(gcf,'color','w');

        if (saveResAndFigure)
            resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V14/'];
            if plotGroup
                resDir = [resDir 'GroupResults/'];
            end
            if not(isfolder(resDir))
                mkdir(resDir)
            end
            if flip == 1
                saveas(fh, [resDir figureSaveId '_CheckerBoard_AE_NoBase.png'])
    %                 saveas(fh, [resDir figureSaveId '_AllEpochCheckerBoard_' num2str(session)],'epsc')
            else
                saveas(fh, [resDir figureSaveId '_CheckerBoard_AE_NoBase_Asym.png'])
            end
        end
        
        if plotGroup
            break
        end
    end
end

%% remove bad muscles before regression analysis
if strcmp(groupID, 'CTS_03')
    badMuscleNames = {'fHIPs'};
elseif contains(groupID,'CTR_02')
    badMuscleNames = {'fTFLs'};
% elseif contains(groupID,'CTS') %needs to be reevaluted
%     badMuscleNames = {'fRFs'};
end
symmetricLabelPrefix = removeBadMuscleIndex(badMuscleNames,newLabelPrefix,true);
newLabelPrefix = removeBadMuscleIndex(badMuscleNames,newLabelPrefix);

%% Regressor V2, prepare data for regressor checkerboards and regression model
% - Update from disucssion on July 12th , 2021
% - Refer to OneNote (updated model) and NTS_05 for naming details

% prepare subjects to plot, make a list potentially combining ind and group
% subjects. this simplifies code repitition to handle group and individual
% subjects plotting.
subjectsToPlot = {};
subjectsToPlotID = {};
subjectsToPlotResDirs = {};
resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V14/'];
if plotIndSubjects
    subjectsToPlot = normalizedTMFullAbrupt.adaptData;
    subjectsToPlotID = subID;
    [subjectsToPlotResDirs{1:n_subjects}] = deal(resDir); %repeat resdir n_subjects times for saving
end
if length(subID) > 1 || plotGroup
    subjectsToPlot{end+1} = normalizedTMFullAbrupt;
    subjectsToPlotID{end+1} = groupID;
    subjectsToPlotResDirs{end+1} = [scriptDir '/RegressionAnalysis/RegModelResults_V14/GroupResults/'];
end

%set up common epochs
ep = defineEpochVR_OG_UpdateV8('nanmean');
epTRBase = ep(strcmp(ep.Properties.ObsNames,'TRbase'),:);
epOGBase = ep(strcmp(ep.Properties.ObsNames,'OGbase'),:);
epAdaptLate = ep(strcmp(ep.Properties.ObsNames,'Adapt_{SS}'),:);
epPost1Early= ep(strcmp(ep.Properties.ObsNames,'Post1_{Early}'),:);
epPost1Late= ep(strcmp(ep.Properties.ObsNames,'Post1_{Late}'),:);
epPost2Early= ep(strcmp(ep.Properties.ObsNames,'Post2_{Early}'),:);
epPosShortLate = ep(strcmp(ep.Properties.ObsNames,'PosShort_{Late}'),:);
epAfterPosShort = ep(strcmp(ep.Properties.ObsNames,'OGAfterPosShort'),:);

%set up variables that could change the regression
usefft = 0; normalizeData = 0;

% FIXME: make this code work for CTR
%             TR: 1,2 trans1; 1,3, trans2; TS: 1,3 for both
for i = 1:length(subjectsToPlot)
    for modelOption = 1:3
        % reset regressor names for each model option, reset reg model versions  
        regressorNames = {'MultiContextAdapt','EnvTransition','MultiContextSwitch','Trans1','Trans2'};
        if (contains(groupID, 'CTS'))
            regModelVersion = 'TS'
        elseif (contains(groupID, 'CTR'))
            regModelVersion = 'TR'
        end
        
        for flip = [1,2]
            if flip == 1
                currLabelPrefix = newLabelPrefix;
            else
                currLabelPrefix = symmetricLabelPrefix;
            end
            fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
            ph=tight_subplot(1,5,[.03 .005],.04,.04);
            Data = cell(1,5); %in order: {'MultiContextAdapt','EnvTransition','MultiContextSwitch','Trans1','Trans2'};

            if modelOption == 1 %trans = multi-env-switch + multi-env-adapt, and multi-env-adapt = -(OGearly - emg(-))
                epNegShortLate = ep(strcmp(ep.Properties.ObsNames,'NegShort_{late}'),:);
                epAfterNegShort = ep(strcmp(ep.Properties.ObsNames,'OGAfterNegShort'),:);
                panel1Title = 'MultiContextAdapt: NegShort_{l} - OGAfterNegShort_{e}';
                [~,~,~,Data{2},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epOGBase,fh,ph(1,2),epOGBase,flip); % space holder 
                title('Space-Holder') %space holder, data doesn't matter, won't be used
            elseif modelOption == 2 %trans = multi-env-switch + multi-env-adapt, and multi-env-adapt = -(OGearly - emg(-)fastest)
                epNegShortLate = ep(strcmp(ep.Properties.ObsNames,'NegPlusDelta_{late}'),:);
                epAfterNegShort = ep(strcmp(ep.Properties.ObsNames,'OGAfterNegPlus'),:);
                panel1Title = 'MultiContextAdapt: NegPlusDelta_{l} - OGAfterNegPlus_{e}';
                [~,~,~,Data{2},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epOGBase,fh,ph(1,2),epOGBase,flip); % space holder 
                title('Space-Holder') %space holder, data doesn't matter, won't be used
            elseif modelOption == 3 %trans = multi-env-switch + within-env-adpt + env-trans, 
%                 and within-env-adapt = EMG(-) - TMSlow, env-switch:
%                 OG-TMfast
                regModelVersion = 'default'
                epNegShortLate = ep(strcmp(ep.Properties.ObsNames,'NegShort_{early}'),:);
                epAfterNegShort = ep(strcmp(ep.Properties.ObsNames,'TMSlowPreNegShort'),:);
                panel1Title = 'WithinContextAdapt: NegShort_{e} - TMSlow{l}';
                regressorNames{1} = 'WithinContextAdapt';
                [~,~,~,Data{2},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epOGBase,fh,ph(1,2),epTRBase,flip); % env-transition: OG-TRbase                
                title('EnvTransition: OGbase - TRbase')
            end
            
            if usefft %use positive short and flip legs later
                [~,~,~,Data{1},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epPosShortLate,fh,ph(1,1),epAfterNegShort,flip); % multi-env-switch
                title(panel1Title)
            else
                [~,~,~,Data{1},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epNegShortLate,fh,ph(1,1),epAfterNegShort,flip); % multi-env-switch
                title(panel1Title)
            end
            [~,~,~,Data{3},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epAfterPosShort,fh,ph(1,3),epPosShortLate,flip); % OG base - TR base, multi-context switching
            title('MultiContextSwitch: OGearly - PosShortLate')
            [~,~,~,Data{4},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epPost1Early,fh,ph(1,4),epAdaptLate,flip); %Post1 - Adaptation_{SS}, transition 1
            title('Tran1')
            [~,~,~,Data{5},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epPost2Early,fh,ph(1,5),epPost1Late,flip); %Post2 early - post 1 late, transition 2
            title('Tran2')

            set(ph(:,1),'CLim',[-1 1]);
            set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1.5);
            set(ph,'FontSize',8)
            pos=get(ph(1,end),'Position');
            axes(ph(1,end))
            colorbar
            set(ph(1,end),'Position',pos);
            set(gcf,'color','w');

            if (saveResAndFigure)    
                if not(isfolder(subjectsToPlotResDirs{i}))
                    mkdir(subjectsToPlotResDirs{i})
                end
                saveas(fh, [subjectsToPlotResDirs{i} subjectsToPlotID{i} 'Checkerboard_ver' num2str(usefft) num2str(normalizeData) regModelVersion '_modelOption_' num2str(modelOption) '_flip_' num2str(flip) '.png'])
%                 saveas(fh, [subjectsToPlotResDirs{i} subjectsToPlotID{i} 'Checkerboard_ver' num2str(usefft) num2str(normalizeData) regModelVersion '_modelOption_' num2str(modelOption) '_flip_' num2str(flip)], 'epsc')
            end

            if flip ~= 2 %run regression on the full (not asymmetry) data
                % run regression and save results
                format compact % format loose %(default)
                modelOption
                % not normalized first, then normalized, arugmnets order: (Data, normalizeData, isGroupData, dataId, resDir, saveResAndFigure, version, usefft) 
                runRegression_V3(Data, false, true, [subjectsToPlotID{i} regModelVersion '_modelOption_' num2str(modelOption) 'flip_' num2str(flip)], resDir, saveResAndFigure, regModelVersion, usefft, regressorNames)
                runRegression_V3(Data, true, true, [subjectsToPlotID{i} regModelVersion '_modelOption_' num2str(modelOption) 'flip_' num2str(flip)], resDir, saveResAndFigure, regModelVersion, usefft, regressorNames)
            else
                asymCos = findCosBtwAsymOfEpochs(Data, size(currLabelPrefix,2))
            end
        end
    end
end
