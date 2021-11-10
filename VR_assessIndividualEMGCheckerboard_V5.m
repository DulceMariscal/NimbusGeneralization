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
groupID = 'CTS';
saveResAndFigure = false;
plotAllEpoch = true;
plotIndSubjects = false;
plotGroup = true;

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
normalizedTMFullAbrupt=normalizedTMFullAbrupt.removeBadStrides;

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
normalizedTMFullAbrupt.removeBadStrides;
normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,ep(1,:));
% normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,refEp);

ll=normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');
%ll = normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^(s|f)[A-Z]+_s');

l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ll,l2);

newLabelPrefix = regexprep(newLabelPrefix,'_s','s');

%% remove bad muscles before regression analysis
badMuscleNames ={}
if strcmp(groupID, 'CTS_03')
    badMuscleNames = {'fHIPs'};
elseif contains(groupID,'CTR_02')
    badMuscleNames = {'fTFLs'};
elseif contains(groupID,'CTS_04')
    badMuscleNames = {'sLGs','fTAs'};
elseif contains(groupID,'CTS_05') %0.0296
    badMuscleNames = {'sLGs'};
elseif contains(groupID,'CTS_06') %needs to be reevaluted
    badMuscleNames = {'sTAs'};
elseif contains(groupID,'CTR')
    badMuscleNames = {'fTFLs','sRFs'};
elseif contains(groupID,'CTS') %needs to be reevaluted
    badMuscleNames = {'sLGs','sTAs'};
    
    
end
symmetricLabelPrefix = removeBadMuscleIndex(badMuscleNames,newLabelPrefix,true);
newLabelPrefix = removeBadMuscleIndex(badMuscleNames,newLabelPrefix);

%% plot epochs
if plotAllEpoch
    
    for i = 1%  :n_subjects
        
        if plotGroup
            adaptDataSubject = normalizedTMFullAbrupt;
            figureSaveId = groupID;
        else
            adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i};
            figureSaveId = subID{i};
        end
        
        adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i};
        
        fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
        ph=tight_subplot(1,length(ep)+2,[.03 .005],.04,.04);
        flip=true;
        
        adaptDataSubject.plotCheckerboards(newLabelPrefix,refEp,fh,ph(1,1),[],flip); %plot TM tied 1 reference
        adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(3,:),fh,ph(1,2),refEp,flip); %plot TR base reference
        adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(1:8,:),fh,ph(1,3:10),refEp,flip);%plot all epochs normalized by the fast baseline
        adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(9,:),fh,ph(1,11),refEpLate,flip);%plot the early Post - late Ada block
        adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(10:11,:),fh,ph(1,12:13),refEp,flip);%plot all remaining epochs normalized by the fast baseline
        adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(12:13,:),fh,ph(1,14:15),refEpSlow,flip);%plot all epochs normalized by the slow baseline (2nd short split)
        adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpSlow,fh,ph(1,16),refEp,flip); %plot TM tied 4 (slow base close to neg/pos short 2)
        adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(14,:),fh,ph(1,17),refEp,flip); %plot TM base slow from the beginning
        
        
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
            resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V15/'];
            if not(isfolder(resDir))
                mkdir(resDir)
            end
            saveas(fh, [resDir subID{i} '_AllEpochCheckerBoard.png'])
            saveas(fh, [resDir subID{i} '_AllEpochCheckerBoard'],'epsc')
        end
    end
end
%% Getting norm of epoch of interest
refEp = defineReferenceEpoch('OGbase',ep);
removeBias=1;
plotGroup=0;

if plotGroup==1
    l=1;
else
    l= 1:n_subjects;
end

if removeBias==1
    bias=refEp;
else
    bias=[];
end
if plotAllEpoch
    
    for i = l
        
        if plotGroup
            adaptDataSubject = normalizedTMFullAbrupt;
            figureSaveId = groupID;
        else
            adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i};
            figureSaveId = subID{i};
        end
        
        adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i};
        
        fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
        ph=tight_subplot(1,length(ep)-3,[.03 .005],.04,.04);
        flip=true;
        
        [~,~,~,Data,~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,refEp,fh,ph(1,1),[],flip); %plot TM tied 1 reference
        title({[refEp.Properties.ObsNames{1} '[' num2str(refEp.Stride_No(1)) ']'] ['Norm=', num2str(norm(Data))]});
        norData=norm(Data);
        VarNames{1,1}= refEp.Properties.ObsNames{1};
        VarNames{1,i+1}=norData;

        for ii=1:8
            [~,~,~,Data,~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(ii,:),fh,ph(1,ii+1),bias,flip);%plot all epochs normalized by the fast baseline          
            norData=norm(Data);
            title({[ep.Properties.ObsNames{ii} '[' num2str(ep.Stride_No(ii)) ']'] ['Norm=', num2str(norData)]});
            VarNames{ii+1,1}= ep.Properties.ObsNames{ii};
            VarNames{ii+1,i+1}=norData;
        end
        
        [~,~,~,Data,~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(9,:),fh,ph(1,10),refEpLate,flip);%plot the early Post - late Ada block
         title({[ep.Properties.ObsNames{9} '[' num2str(ep.Stride_No(9)) ']'] ['Norm=', num2str(norm(Data))]});
        norData=norm(Data);
        VarNames{10,1}= ep.Properties.ObsNames{9};
        VarNames{10,i+1}=norData;
        
        for ii=10:11
            [~,~,~,Data,~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(ii,:),fh,ph(1,ii+1),bias,flip);%plot all remaining epochs normalized by the fast baseline
            norData=norm(Data);
            title({[ep.Properties.ObsNames{ii} '[' num2str(ep.Stride_No(ii)) ']'] ['Norm=', num2str(norData)]});
            VarNames{ii+1,1}= ep.Properties.ObsNames{ii};
            VarNames{ii+1,i+1}=norData;
        end
        
%         T = cell2table(VarNames,'VariableNames',{'Epoch','Norm'});
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
            resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V15/'];
            if not(isfolder(resDir))
                mkdir(resDir)
            end
            saveas(fh, [resDir subID{i} '_AllEpochCheckerBoard.png'])
            saveas(fh, [resDir subID{i} '_AllEpochCheckerBoard'],'epsc')
        end
    end
end

if plotGroup
    GroupTable = cell2table([VarNames],'VariableNames',{'Epoch',groupID});
    save(['WithBadStridesGNorm_', groupID,'_0', num2str(removeBias)], 'GroupTable')
else
    IndvTable = cell2table([VarNames],'VariableNames',{'Epoch',subID{:}});
    meanTable = array2table( nanmean(cell2mat(VarNames(:,2:end)),2),'VariableNames',convertCharsToStrings(groupID));
    save(['WithBadStridesNorm_', groupID,'_0', num2str(removeBias)], 'IndvTable', 'meanTable')
end

%% plot subsets of epochs: AE with context specific baseline correction
%AE only pertains to session 1 and long protocols.
refEpOG = defineReferenceEpoch('OGbase',ep);
refEpTR = defineReferenceEpoch('TRbase',ep);
post1ep = ep(strcmp(ep.Properties.ObsNames,'Post1_{Early}'),:);
post2ep = ep(strcmp(ep.Properties.ObsNames,'Post2_{Early}'),:);

post1lateep = ep(strcmp(ep.Properties.ObsNames,'Post1_{Late}'),:);
post2lateep = ep(strcmp(ep.Properties.ObsNames,'Post2_{Late}'),:);

Data = cell(1,4);

for flip = [1]%,2] %2 legs separate first (flip = 1) and then asymmetry (flip = 2)
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
        ph=tight_subplot(1,8)%,[.03 .005],.04,.04);
        
        % plot after effects only
        [~,~,~,Data{1},~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpOG,fh,ph(1,1),[],flip); %plot OG base
        [~,~,~,Data{2},~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpTR,fh,ph(1,2),[],flip); %plot OG base with shoe
        
        %         if (contains(groupID, 'TS'))%correct post 1 with OG no nimbus, post 2 with OG with nimbus, i.e.,TR
        %             adaptDataSubject.plotCheckerboards(newLabelPrefix,post1ep,fh,ph(1,3),refEpOG,flip); %post1 is OG
        %             adaptDataSubject.plotCheckerboards(newLabelPrefix,post2ep,fh,ph(1,4),refEpTR,flip); %post2 is with Nimbus(TR)
        %         elseif (contains(groupID, 'TR')) %correct post 1 with TR(nimbus), post 2 with OG (No nimbus)
        %             adaptDataSubject.plotCheckerboards(newLabelPrefix,post1ep,fh,ph(1,3),refEpTR,flip);
        %             adaptDataSubject.plotCheckerboards(newLabelPrefix,post2ep,fh,ph(1,4),refEpOG,flip);
        %         end
        
        [~,~,~,Data{3},~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,post1ep,fh,ph(1,3),[],flip);
        [~,~,~,Data{4},~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,post2ep,fh,ph(1,4),[],flip);
        [~,~,~,Data{5},~]=adaptDataSubject.plotCheckerboards(newLabelPrefix,post1lateep,fh,ph(1,5),[],flip);
        [~,~,~,Data{6},~]=adaptDataSubject.plotCheckerboards(newLabelPrefix,post2lateep,fh,ph(1,6),[],flip);
        
        if strcmpi(regModelVersion, 'TR')
            adaptDataSubject.plotCheckerboards(newLabelPrefix,post1lateep,fh,ph(1,7),refEpTR,flip);
            title('Post1_{Late}-TRbase_{late}')
            
            disp('Cosine(Post1_{Late},TRbase_{late})')
            cos= Cosine2Matrix(Data{5},Data{2})
            
            
            
            adaptDataSubject.plotCheckerboards(newLabelPrefix,post2lateep,fh,ph(1,8),refEpOG,flip);
            title('Post2_{Late}-OGbase_{late}')
            
            
            disp('Cosine(Post2_{Late},OGbase_{late})')
            cos= Cosine2Matrix(Data{1},Data{6})
            
        else
            
            adaptDataSubject.plotCheckerboards(newLabelPrefix,post1lateep,fh,ph(1,7),refEpOG,flip);
            title('Post1_{Late}-OGbase_{late}')
            disp('Cosine(Post1_{Late},OGbase_{late})')
            cos= Cosine2Matrix(Data{1},Data{5})
            
            %             cosine(Data{1},Data{3})
            
            adaptDataSubject.plotCheckerboards(newLabelPrefix,post2lateep,fh,ph(1,8),refEpTR,flip);
            title('Post2_{Late}-TRbase_{late}')
            disp('Cosine(Post2_{Late},TRbase_{late})')
            cos= Cosine2Matrix(Data{2},Data{6})
            %             cosine(Data{2},Data{4})
        end
        
        
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
        
        currLabelPrefix = newLabelPrefix;
        
        
        
        if (saveResAndFigure)
            resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V15/'];
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
badMuscleNames ={}
if strcmp(groupID, 'CTS_03')
    badMuscleNames = {'fHIPs'};
elseif contains(groupID,'CTR_02')
    badMuscleNames = {'fTFLs'};
elseif contains(groupID,'CTS_04')
    badMuscleNames = {'sLGs','fTAs'};
elseif contains(groupID,'CTS_05') %0.0296
    badMuscleNames = {'sLGs'};
elseif contains(groupID,'CTS_06') %needs to be reevaluted
    badMuscleNames = {'sTAs','fTAs'};
elseif contains(groupID,'CTS') %needs to be reevaluted
    badMuscleNames = {'sLGs','sTAs'};
    
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
resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V15/'];
if plotIndSubjects
    subjectsToPlot = normalizedTMFullAbrupt.adaptData;
    subjectsToPlotID = subID;
    [subjectsToPlotResDirs{1:n_subjects}] = deal(resDir); %repeat resdir n_subjects times for saving
end
if length(subID) > 1 || plotGroup 
    subjectsToPlot{end+1} = normalizedTMFullAbrupt;
    subjectsToPlotID{end+1} = groupID;
    subjectsToPlotResDirs{end+1} = [scriptDir '/RegressionAnalysis/RegModelResults_V15/GroupResults/'];
end



%set up common epochs
ep = defineEpochVR_OG_UpdateV8('nanmean');
epTRBase = ep(strcmp(ep.Properties.ObsNames,'TRbase'),:);
epOGBase = ep(strcmp(ep.Properties.ObsNames,'OGbase'),:);
epAdaptLate = ep(strcmp(ep.Properties.ObsNames,'Adapt_{SS}'),:);
epPost1Early= ep(strcmp(ep.Properties.ObsNames,'Post1_{Early}'),:);
epPost1Late= ep(strcmp(ep.Properties.ObsNames,'Post1_{Late}'),:);
epPost2Early= ep(strcmp(ep.Properties.ObsNames,'Post2_{Early}'),:);
epPosShortLate = ep(strcmp(ep.Properties.ObsNames,'PosShort_{late}'),:);
epAfterPosShort = ep(strcmp(ep.Properties.ObsNames,'OGAfterPosShort'),:);
epBeforePosShort = ep(strcmp(ep.Properties.ObsNames,'TMfastBeforePosShort'),:);
%set up variables that could change the regression
usefft = 0; normalizeData = 0;
normalize=0; %Normalize data before computing differences

% FIXME: make this code work for CTR
%             TR: 1,2 trans1; 1,3, trans2; TS: 1,3 for both
% TR has to think about the options
for i = 1:length(subjectsToPlot)
    for modelOption = 3%1:3
        % reset regressor names for each model option, reset reg model versions
        regressorNames = {'MultiContextAdapt','WithinContextSwitch','MultiContextSwitch','Trans1','Trans2'};
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
                [~,~,~,Data{2},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epOGBase,fh,ph(1,2),epOGBase,flip,'nanmean'); % space holder
                title('Space-Holder') %space holder, data doesn't matter, won't be used
            elseif modelOption == 2 %trans = multi-env-switch + multi-env-adapt, and multi-env-adapt = -(OGearly - emg(-)fastest)
                epNegShortLate = ep(strcmp(ep.Properties.ObsNames,'NegPlusDelta_{late}'),:);
                epAfterNegShort = ep(strcmp(ep.Properties.ObsNames,'OGAfterNegPlus'),:);
                panel1Title = 'MultiContextAdapt: NegPlusDelta_{l} - OGAfterNegPlus_{e}';
                [~,~,~,Data{2},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epOGBase,fh,ph(1,2),epOGBase,flip,'nanmean'); % space holder
                title('Space-Holder') %space holder, data doesn't matter, won't be used
            elseif modelOption == 3 ||modelOption == 6%trans = multi-env-switch + within-env-adpt + env-trans,
                %                 and within-env-adapt = EMG(-) - TMSlow, env-switch:
                %                 OG-TMfast
                regModelVersion = 'default'
%                 epNegShortLate = ep(strcmp(ep.Properties.ObsNames,'NegShort_{early}'),:);
                epNegShortLate = ep(strcmp(ep.Properties.ObsNames,'NegShort_{late}'),:);
                epAfterNegShort = ep(strcmp(ep.Properties.ObsNames,'TMSlowPreNegShort'),:);
%                 panel1Title = 'WithinContextAdapt: NegShort_{e} - TMSlow{l}';
                panel1Title = 'Adapt: NegShort_{l} - TMSlow{l}';
                regressorNames{1} = 'Adapt';
                [~,~,~,Data{3},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epOGBase,fh,ph(1,3),epTRBase,flip,'nanmean'); % env-transition: OG-TRbase
                title('MultiContextSwitch: OGbase - TRbase')
                
            elseif  modelOption == 5 %trans = multi-env-switch + multi-env-adapt, and multi-env-adapt = -(TMslow - emg(-))
                epNegShortLate = ep(strcmp(ep.Properties.ObsNames,'NegShort_{late}'),:);
                epAfterNegShort = ep(strcmp(ep.Properties.ObsNames,'TMSlowPreNegShort'),:);
                panel1Title = 'MultiContextAdapt: NegShort_{l} -TMSlowPreNegShort_{l}';
                [~,~,~,Data{2},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epOGBase,fh,ph(1,2),epOGBase,flip,'nanmean'); % space holder
                title('Space-Holder') %space holder, data doesn't matter, won't be used
            end
            
            if usefft %use positive short and flip legs later
                [~,~,~,Data{1},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epPosShortLate,fh,ph(1,1),epAfterNegShort,flip,'nanmean'); % multi-env-switch
                title(panel1Title)
            else
                [~,~,~,Data{1},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epNegShortLate,fh,ph(1,1),epAfterNegShort,flip,'nanmean'); % multi-env-switch
                title(panel1Title)
            end
            
            if  modelOption == 5 || modelOption == 3 
            [~,~,~,Data{2},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epBeforePosShort,fh,ph(1,2),epPosShortLate,flip,'nanmean'); % TM fast - Post Short-  multi-context switching
            title('WithinContextSwitch: TMfast_{l} - PosShortLate')
            
            elseif modelOption == 6 
                epNegShortLate = ep(strcmp(ep.Properties.ObsNames,'NegShort_{late}'),:);
                epAfterNegShort = ep(strcmp(ep.Properties.ObsNames,'OGAfterNegShort'),:);
                panel1Title = 'MultiContextAdapt: NegShort_{l} - OGAfterNegShort_{e}';
                [~,~,~,Data{2},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epOGBase,fh,ph(1,2),epOGBase,flip,'nanmean'); % space holder
                title('Space-Holder') %space holder, data doesn't matter, won't be used
                regModelVersion = 'Adaptive_EnvTransition'
                
                
            
            else
               
            [~,~,~,Data{3},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epAfterPosShort,fh,ph(1,3),epPosShortLate,flip,'nanmean'); % OG base - TR base, multi-context switching
            title('MultiContextSwitch: OGearly - PosShortLate')
            end
            [~,~,~,Data{4},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epPost1Early,fh,ph(1,4),epAdaptLate,flip,'nanmean'); %Post1 - Adaptation_{SS}, transition 1
            title('Tran1')
            [~,~,~,Data{5},~] = subjectsToPlot{i}.plotCheckerboards(currLabelPrefix,epPost2Early,fh,ph(1,5),epPost1Late,flip,'nanmean'); %Post2 early - post 1 late, transition 2
            title('Tran2')
            
            set(ph(:,1),'CLim',[-1 1]*1.5);
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
                runRegression_V3(Data, false, isa(subjectsToPlot{1},'groupAdaptationData'), [subjectsToPlotID{i} regModelVersion '_modelOption_' num2str(modelOption) 'flip_' num2str(flip)], subjectsToPlotResDirs{i}, saveResAndFigure, regModelVersion, usefft, regressorNames)
                runRegression_V3(Data, true, isa(subjectsToPlot{1},'groupAdaptationData'), [subjectsToPlotID{i} regModelVersion '_modelOption_' num2str(modelOption) 'flip_' num2str(flip)], subjectsToPlotResDirs{i}, saveResAndFigure, regModelVersion, usefft, regressorNames)
                %                 function runRegression_V3(Data, normalizeData, isGroupData, dataId, resDir, saveResAndFigure, version, usefft, regressorNames)
                
            else
                asymCos = findCosBtwAsymOfEpochs(Data, size(currLabelPrefix,2),regressorNames)
            end
        end
    end
end
%%


