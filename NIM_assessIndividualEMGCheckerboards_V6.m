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
groupID = 'NTS'; % groupID to grab all subjects from the same group. If only want to grab 1 subject, specify subject ID.
Testing = true;
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

if length(subID) > 1
    if (contains(groupID, 'NTS'))
    Testing = true; %if group data use the shared epochs
    else
         Testing = false; %if group data use the shared epochs
    end
end

regModelVersion = 'default'
if (contains(groupID, 'NTS'))
    regModelVersion = 'TS'
elseif (contains(groupID, 'NTR'))
    regModelVersion = 'TR'
end

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
        session2Data = session2Data.normalizeToBaselineEpoch(newLabelPrefix,refEpSession2);
        session2Data =session2Data.removeBadStrides;
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
        refEpSession2 = defineReferenceEpoch('Base',epSession2);
        session2Data = session2Data.normalizeToBaselineEpoch(newLabelPrefix,refEpSession2);
        session2Data =session2Data.removeBadStrides;
        ll=session2Data.adaptData{1}.data.getLabelsThatMatch('^Norm');
        l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
        session2Data=session2Data.renameParams(ll,l2);
        totalSessions = 1;
    end
end
%define some common reference epochs
refEpTR = defineReferenceEpoch('OGNimbus',ep);
refEpLate = defineReferenceEpoch('Adaptation',ep);
refEpOG = defineReferenceEpoch('BaseNoShoes',ep);
%
% normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,refEpTR);
normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,ep(1,:));
normalizedTMFullAbrupt=normalizedTMFullAbrupt.removeBadStrides;
ll=normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');
l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ll,l2);

newLabelPrefix = regexprep(newLabelPrefix,'_s','s');
%% remove bad muscles
% NTS: remove sHIP and sVL
% NTR: remove fTFL
% for session 2 data
if strcmp(groupID, 'NTR_03')
    badMuscleNames = {'fTFLs'};
elseif strcmp(groupID, 'NTR_04')
    badMuscleNames = {'sLGs'};
elseif strcmp(groupID, 'NTR')
    badMuscleNames = {'sLGs','fTFLs','fSEMTs','sSEMTs'};
    %      badMuscleNames = {'sLGs','fTFLs','fLGs','sTFLs'};
elseif  strcmp(groupID, 'NTR_05')
    badMuscleNames = {'fSEMTs','sSEMTs'};
% elseif  strcmp(groupID, 'NTS')
%     badMuscleNames = {'fRFs','sRFs','sVLs','fVLs','sHIPs','fHIPs'};
elseif  strcmp(groupID, 'NTS')
    badMuscleNames = {'sHIPs'};
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
%  regModelVersion = 'default'
usefft = 0; normalizeData = 0;

%NTS splitCount = 1
%NTR 
splitCount = 1
%%
for splitCount =  [1]%here split count used interchangeable as model options
    splitCount
    if Testing
        ep = epLong;
        if ~isempty(session2subID)
            epSession2;
        end
        
    else
        ep=defineEpochNIM_OG_UpdateV3('nanmean');
        %         multi env and transition 1 and 2 always use this, deltaAdapt and
        %         nonAdapt could be from this or the session2
        if ~isempty(session2subID)
            epSession2 = defineEpochNIM_OG_UpdateV4('nanmean', groupID);
        end
        refEpAdaptLate = defineReferenceEpoch('Task_{Switch}',ep);
        refEpOGpost= defineReferenceEpoch('Post1_{Late}',ep);
    end
    
    
    % Plot checkerboards per subject
   if  plotIndSubjects || length(subID) == 1 %length(subID) > 1 || plotGroup % 
        %         close all;
        for i = 1:n_subjects
            if i ==2
                break
            end
                
            for flip = [1]%,2]
                adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i};
%                 adaptDataSubject = normalizedTMFullAbrupt;
                if ~isempty(session2subID)
                    adaptDataSubjectSession2 = session2Data.adaptData{1, i};
                end
              
                fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
                ph=tight_subplot(1,5,[.03 .005],.04,.04);
                %             flip=2; %plot asymmetry
                
                Data = {}; %in order: adapt, dataEnvSwitch, dataTaskSwitch, dataTrans1, dataTrans2
                %all labels should be the same, no need to save again.
                if ~Testing
                    if splitCount == 1
                        if usefft
                            [~,~,labels,Data{1},dataRef2]=adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(3,:),fh,ph(1,1),epSession2(14,:),flip); %  EMG_split(+) - TM base slow, adaptation, later will be leg swapped
                        else
                            [~,~,labels,Data{1},dataRef2]=adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(2,:),fh,ph(1,1),epSession2(14,:),flip); %  EMG_split(-) - TM base slow, adaptation
                        end
                        [~,~,~,Data{2},~] = adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(1,:),fh,ph(1,2),epSession2(3,:),flip); % Noadapt (env-driven/within-env), - EMGon(+) = TM base - EMG_on(+)
                    end
                    [~,~,~,Data{3},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(1,:),fh,ph(1,3),ep(6,:),flip); %  -(TR base - OG base) = OG base - TR base (NIM base), env switching
                    [~,~,~,Data{4},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(8,:),fh,ph(1,4),refEpAdaptLate,flip); %OGafter - Adaptation_{SS} , transition 1
                    [~,~,~,Data{5},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(11,:),fh,ph(1,5),refEpOGpost,flip); %Nimbus post early - OG post late, transition 2
                else
                    %                 'Adapt', 'WithinContextSwitch', 'MultiContextSwitch',
                    regressorNames = {'MultiContextAdapt','EnvTransition','MultiContextSwitch','Trans1','Trans2'};
                    if (contains(groupID, 'NTS'))
                        regModelVersion = 'TS'
                    elseif (contains(groupID, 'NTR'))
                        regModelVersion = 'TR'
                    end
                    switch splitCount
                        case {1} %env switch use OGnoNimbus - OGNimbus
                            [~,~,~,Data{1},~] =adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(12,:),fh,ph(1,1),epSession2(11,:),flip); % adapt
                            title('Within-Env-Adapt: NegShort-TMSlow') % (-) early - TM slow
                            regressorNames{1} = 'Adapt';

                            [~,~,~,Data{2},~] = adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(8,:),fh,ph(1,2),epSession2(9,:),flip); % MultiContextSwitch, TMfast - onPlusLate
                            title('Multi-Env-Switch: TMfast-PosShort') 
                            regressorNames{2} = 'WithinContextSwitch';
                            
                            [~,~,~,Data{3},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(1,:),fh,ph(1,3),ep(8,:),flip);
                            title('Env-Switch: OG-OGNimbus')  % OG - OGNimbus 
                            regModelVersion = 'default'
                    end

                    end
                    [~,~,~,Data{4},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(10,:),fh,ph(1,4),ep(9,:),flip); %Post1 early - Adaptation_{SS} , transition 1
                    title('Transition 1')
                    [~,~,~,Data{5},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(13,:),fh,ph(1,5),ep(12,:),flip); %Post2 early - Post 1 late, transition 2
                    title('Transition 2')
                end
                
                set(ph(:,1),'CLim',[-1 1]*1.5);
                set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1.5);
                set(ph,'FontSize',8)
                pos=get(ph(1,end),'Position');
                axes(ph(1,end))
                colorbar
                set(ph(1,end),'Position',pos);
                set(gcf,'color','w');
                
                resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V14/'];
                if saveResAndFigure
                    if not(isfolder(resDir))
                        mkdir(resDir)
                    end
                    saveas(fh, [resDir subID{i} '_Checkerboard_Asym_ver' num2str(usefft) num2str(normalizeData) regModelVersion '_split_' num2str(splitCount) 'flip_' num2str(flip) '.png'])
                    %                 saveas(fh, [resDir subID{i} '_Checkerboard_ver' num2str(usefft) num2str(normalizeData) regModelVersion '_split_' num2str(splitCount)],'epsc')
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
end

%%
% plot checkerboard per group
splitCount = 1
    if ~length(subID) > 1 || plotGroup
        for flip = [1]
            fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
            ph=tight_subplot(1,5,[.03 .005],.04,.04);
             
          
            Data = {}; %in order: {'Adapt','WithinContextSwitch','MultiContextSwitch','Trans1','Trans2'};
            %                         [~,~,labels,dataE{1},dataRef{1}]=normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep,fh,ph(1,2:end),refEp,flip);%Second, the rest:
            
            if ~Testing

                if splitCount == 1
                    if usefft
                        [~,~,labels,Data{1},dataRef2]=session2Data.plotCheckerboards(newLabelPrefix,epSession2(3,:),fh,ph(1,1),epSession2(14,:),flip); %  EMG_split(+) - TM base slow, adaptation, later will be leg swapped
                    else
                        [~,~,labels,Data{1},dataRef2]=session2Data.plotCheckerboards(newLabelPrefix,epSession2(2,:),fh,ph(1,1),epSession2(14,:),flip); %  EMG_split(-) - TM base slow, adaptation
                    end
                    [~,~,~,Data{2},~] = session2Data.plotCheckerboards(newLabelPrefix,epSession2(1,:),fh,ph(1,2),epSession2(3,:),flip); % Noadapt (env-driven/within-env), - EMGon(+) = TM base - EMG_on(+)
                    
                end
                [~,~,~,Data{3},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(1,:),fh,ph(1,3),ep(6,:),flip); %  OG base - TR base = -(TR base - OG base), env switching
                [~,~,~,Data{4},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(8,:),fh,ph(1,4),refEpAdaptLate,flip); %OGafter - Adaptation_{SS}, transition 1
                [~,~,~,Data{5},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(11,:),fh,ph(1,5),refEpOGpost,flip); %TM post VR early - OG post late, transition 2
            else
                %                 'Adapt', 'WithinContextSwitch', 'MultiContextSwitch',
                epSession2 = defineEpochNimbusShoesTesting_Session2('nanmean');
                ep=defineEpochNimbusShoes_longProtocol('nanmean');
                
                regressorNames = {'MultiContextAdapt','EnvTransition','MultiContextSwitch','Trans1','Trans2'};
                if (contains(groupID, 'NTS'))
                    regModelVersion = 'TS'
                elseif (contains(groupID, 'NTR'))
                    regModelVersion = 'TR'
                end 
                switch splitCount
                    case {1} %env switch use OGnoNimbus - OGNimbus
%                         [~,~,~,Data{1},~] =normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(6,:),fh,ph(1,1),ep(5,:),flip); % adapt
%                         title('Within-Env-Adapt: NegShort-TMSlow') % (-) early - TM slow
%                         regressorNames{1} = 'WithinContextAdapt';
%                         
%                         [~,~,~,Data{2},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(2,:),fh,ph(1,2),ep(21,:),flip); % MultiContextSwitch, OG early - onPlusLate
%                         title('Multi-Env-Switch: TMfast-PosShort_{late}')
%                              regressorNames{2} = 'WithinContextSwitch';
%                         
%                         [~,~,~,Data{3},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(1,:),fh,ph(1,3),ep(8,:),flip);
%                         title('Env-Switch: OG-OGNimbus')  % OG - TM fast
%                         regModelVersion = 'default'
%                         
                            [~,~,~,Data{1},~] =session2Data.plotCheckerboards(newLabelPrefix,epSession2(12,:),fh,ph(1,1),epSession2(11,:),flip); % adapt
                            title('Within-Env-Adapt: NegShort-TMSlow') % (-) early - TM slow
                            regressorNames{1} = 'Adapt';

                            [~,~,~,Data{2},~] = session2Data.plotCheckerboards(newLabelPrefix,epSession2(8,:),fh,ph(1,2),epSession2(9,:),flip); % MultiContextSwitch, TMfast - onPlusLate
                            title('Multi-Env-Switch: TMfast-PosShort') 
                            regressorNames{2} = 'WithinContextSwitch';
                            
                            [~,~,~,Data{3},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(1,:),fh,ph(1,3),ep(8,:),flip);
                            title('Env-Switch: OG-OGNimbus')  % OG - OGNimbus 
                            regModelVersion = 'default'

                end
    
                [~,~,~,Data{4},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(10,:),fh,ph(1,4),ep(9,:),flip); %Post1 early - Adaptation_{SS} , transition 1
                title('Transition 1')
                [~,~,~,Data{5},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(13,:),fh,ph(1,5),ep(12,:),flip); %Post2 early - Post 1 late, transition 2
                title('Transition 2')
            end
            
            set(ph(:,1),'CLim',[-1 1]*1.5);
            %     set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*2);
            set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1.5);
            set(ph,'FontSize',8)
            pos=get(ph(1,end),'Position');
            axes(ph(1,end))
            colorbar
            set(ph(1,end),'Position',pos);
            
            set(gcf,'color','w');
            
            resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V14/GroupResults/'];
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
    end
%% plot all epochs for all relevant conditions
if plotAllEpoch
    for session = 1:totalSessions
        if Testing
            subjectNum = n_subjects;
            currData = normalizedTMFullAbrupt;
            currRefEp = refEpTR;
            ep = epLong;
        else
            if session == 1
                subjectNum = n_subjects;
                currData = normalizedTMFullAbrupt;
                ep = epSession1;
                currRefEp = refEpTR;
            else
                subjectNum = session2_n_subjects;
                currData = session2Data;
                ep = epSession2;
                currRefEp = refEpSession2;
            end
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
                resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V14/'];
                if not(isfolder(resDir))
                    mkdir(resDir)
                end
                saveas(fh, [resDir subID{i} '_AllEpochCheckerBoard_' num2str(session) '.png'])
                %                 saveas(fh, [resDir subID{i} '_AllEpochCheckerBoard_' num2str(session)],'epsc')
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
        
        %     flip=true;
        
        % plot after effects only
        adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpOG,fh,ph(1,1),[],flip); %plot OG base
        adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpTR,fh,ph(1,2),[],flip); %plot OG base with shoe
        
        %         if (contains(groupID, 'NTS'))%correct post 1 with OG no nimbus, post 2 with OG with nimbus, i.e.,TR
        %             adaptDataSubject.plotCheckerboards(newLabelPrefix,post1ep,fh,ph(1,3),refEpOG,flip); %post1 is OG
        %             adaptDataSubject.plotCheckerboards(newLabelPrefix,post2ep,fh,ph(1,4),refEpTR,flip); %post2 is with Nimbus(TR)
        %         elseif (contains(groupID, 'NTR')) %correct post 1 with TR(nimbus), post 2 with OG (No nimbus)
        %             adaptDataSubject.plotCheckerboards(newLabelPrefix,post1ep,fh,ph(1,3),refEpTR,flip);
        %             adaptDataSubject.plotCheckerboards(newLabelPrefix,post2ep,fh,ph(1,4),refEpOG,flip);
        %         end
        
        adaptDataSubject.plotCheckerboards(newLabelPrefix,post1ep,fh,ph(1,3),[],flip);
        adaptDataSubject.plotCheckerboards(newLabelPrefix,post2ep,fh,ph(1,4),[],flip);
        adaptDataSubject.plotCheckerboards(newLabelPrefix,post1lateep,fh,ph(1,5),[],flip);
        adaptDataSubject.plotCheckerboards(newLabelPrefix,post2lateep,fh,ph(1,6),[],flip);
        
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
        
        if (saveResAndFigure)
            resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V14/'];
            if plotGroup
                resDir = [resDir 'GroupResults/'];
            end
            if not(isfolder(resDir))
                mkdir(resDir)
            end
            if flip == 1
                saveas(fh, [resDir figureSaveId '_CheckerBoard_AE_NoBase_Trans12.png'])
                %                 saveas(fh, [resDir figureSaveId '_AllEpochCheckerBoard_' num2str(session)],'epsc')
            else
                saveas(fh, [resDir figureSaveId '_CheckerBoard_AE_NoBase_Asym_Trans12.png'])
            end
        end
        
        if plotGroup
            break
        end
    end
end

%% Getting norm of epoch of interest
VarNames=[];
removeBias=1;
plotGroup=0;

if plotGroup==1
    l=1;
else
    l= 1:n_subjects;
end

if strcmp(groupID,'NTS')
    refEpTR = defineReferenceEpoch('BaseNoShoes',ep);
elseif strcmp(groupID,'NTR')
    refEpTR = defineReferenceEpoch('OGNimbus',ep);
end

if removeBias==1
    bias=refEpTR;
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
        ph=tight_subplot(1,length(ep)+1,[.03 .005],.04,.04);
        flip=true;
        
%         [~,~,~,Data,~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpTR,fh,ph(1,1),[],flip); %plot TM tied 1 reference
%         title({[refEpTR.Properties.ObsNames{1} '[' num2str(refEpTR.Stride_No(1)) ']'] ['Norm=', num2str(norm(Data))]});
%         norData=norm(Data);
%         VarNames{1,1}= refEpTR.Properties.ObsNames{1};
%         VarNames{1,i+1}=norData;

        
        if strcmp(groupID,'NTS')
            refEpTR = defineReferenceEpoch('BaseNoShoes',ep);
            
            [~,~,~,Data,~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpTR,fh,ph(1,1),[],flip); %plot TM tied 1 reference
            title({[refEpTR.Properties.ObsNames{1} '[' num2str(refEpTR.Stride_No(1)) ']'] ['Norm=', num2str(norm(Data))]});
            norData=norm(Data);
            VarNames{1,1}= refEpTR.Properties.ObsNames{1};
            VarNames{1,i+1}=norData;

            
            for ii=1:6
                [~,~,~,Data,~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(ii,:),fh,ph(1,ii+1),bias,flip);%plot all epochs normalized by the fast baseline
                norData=norm(Data);
                title({[ep.Properties.ObsNames{ii} '[' num2str(ep.Stride_No(ii)) ']'] ['Norm=', num2str(norData)]});
                VarNames{ii+1,1}= ep.Properties.ObsNames{ii};
               VarNames{ii+1,i+1}=norData;
            end
            
            [~,~,~,Data,~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(7,:),fh,ph(1,8),refEpLate,flip);%plot the early Post - late Ada block
            title({[ep.Properties.ObsNames{7} '[' num2str(ep.Stride_No(9)) ']'] ['Norm=', num2str(norm(Data))]});
        	norData=norm(Data);
            VarNames{8,1}= ep.Properties.ObsNames{7};
            VarNames{8,i+1}=norData;
            
            for ii=8:11
                [~,~,~,Data,~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(ii,:),fh,ph(1,ii+1),bias,flip);%plot all remaining epochs normalized by the fast baseline
                norData=norm(Data);
                title({[ep.Properties.ObsNames{ii} '[' num2str(ep.Stride_No(ii)) ']'] ['Norm=', num2str(norData)]});
                VarNames{ii+1,1}= ep.Properties.ObsNames{ii};
                VarNames{ii+1,i+1}=norData;
            end
            
        elseif strcmp(groupID,'NTR')
            
            [~,~,~,Data,~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpTR,fh,ph(1,1),[],flip); %plot TM tied 1 reference
            title({[refEpTR.Properties.ObsNames{1} '[' num2str(refEpTR.Stride_No(1)) ']'] ['Norm=', num2str(norm(Data))]});
            norData=norm(Data);
            VarNames{1,1}= refEpTR.Properties.ObsNames{1};
            VarNames{1,i+1}=norData;

            
            for ii=[1:2 5:6]
                [~,~,~,Data,~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(ii,:),fh,ph(1,ii+1),bias,flip);%plot all epochs normalized by the fast baseline
                norData=norm(Data);
                title({[ep.Properties.ObsNames{ii} '[' num2str(ep.Stride_No(ii)) ']'] ['Norm=', num2str(norData)]});
                VarNames{ii+1,1}= ep.Properties.ObsNames{ii};
                VarNames{ii+1,i+1}=norData;
            end
            r=0;
            for ii=[5 7]
                r=r+1;
                p=[4 5];
                [~,~,~,Data,~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,epSession2(ii,:),fh,ph(1,p(r)),bias,flip);
                title({[epSession2.Properties.ObsNames{ii} '[' num2str(epSession2.Stride_No(ii)) ']'] ['Norm=', num2str(norm(Data))]});
                norData=norm(Data);
                VarNames{p(r),1}= epSession2.Properties.ObsNames{ii};
                VarNames{p(r),i+1}=norData;
            end
           
            
            [~,~,~,Data,~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(7,:),fh,ph(1,8),refEpLate,flip);%plot the early Post - late Ada block
            title({[ep.Properties.ObsNames{7} '[' num2str(ep.Stride_No(9)) ']'] ['Norm=', num2str(norm(Data))]});
            norData=norm(Data);
            VarNames{8,1}= ep.Properties.ObsNames{7};
            VarNames{8,i+1}=norData;
            
            
            for ii=8:11
                [~,~,~,Data,~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(ii,:),fh,ph(1,ii+1),bias,flip);%plot all remaining epochs normalized by the fast baseline
                norData=norm(Data);
                title({[ep.Properties.ObsNames{ii} '[' num2str(ep.Stride_No(ii)) ']'] ['Norm=', num2str(norData)]});
                VarNames{ii+1,1}= ep.Properties.ObsNames{ii};
                VarNames{ii+1,i+1}=norData;
            end
            
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


