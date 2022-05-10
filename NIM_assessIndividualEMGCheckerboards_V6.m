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
% refEpTR = defineReferenceEpoch('OGNimbus',ep);
% refEpLate = defineReferenceEpoch('Adaptation',ep);
refEpOG = defineReferenceEpoch('OGBase',ep);
%
% normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,refEpTR);
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

%NTS splitCount = 1
%NTR
splitCount = 1
% Testing=1

%%
for splitCount =  [1]%here split count used interchangeable as model options
    splitCount
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
        %         multi env and transition 1 and 2 always use this, deltaAdapt and
        %         nonAdapt could be from this or the session2
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
    
    
    [Data,regressorNames]=RegressionsGeneralization(newLabelPrefix,normalizedTMFullAbrupt,session2Data,1,0,NegShort,TMbeforeNeg,PosShort,TMbeforePos,...
        AdaptLate,Post1Early,Post1Late,Post2Early, OGpostPosEarly, OGbase, EnvBase);
    

    
    % Plot checkerboards per subject
%     if  plotIndSubjects || length(subID) > 1 %length(subID) > 1 || plotGroup %
%         %         close all;
%         for i = 1:n_subjects
%             disp(['subject=', num2str(i)])
%             %             if i ==2
%             %                 break
%             %             end
%             %
%             for flip = [1]%,2]
%                 adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i};
%                 %                 adaptDataSubject = normalizedTMFullAbrupt;
%                 if ~isempty(session2subID)
%                     adaptDataSubjectSession2 = session2Data.adaptData{1, i};
%                 end
%                 
%                 fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
%                 ph=tight_subplot(1,6,[.03 .005],.04,.04);
%                 %             flip=2; %plot asymmetry
%                 
%                 Data = {}; %in order: adapt, dataEnvSwitch, dataTaskSwitch, dataTrans1, dataTrans2
%                 %all labels should be the same, no need to save again.
%                 if ~Testing
%                     regressorNames = {'MultiContextAdapt','EnvTransition','MultiContextSwitch','Trans1','Trans2','Trans3'};
%                     if splitCount == 1
%                         if usefft
%                             [~,~,labels,Data{1},dataRef2]=adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(8,:),fh,ph(1,1),epSession2(2,:),flip); %  EMG_split(+) - TM base slow, adaptation, later will be leg swapped
%                         else
%                             [~,~,labels,Data{1},dataRef2]=adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(11,:),fh,ph(1,1),epSession2(2,:),flip); %  EMG_split(-) - TM base slow, adaptation
%                         end
%                         title('Within-Env-Adapt: NegShort-TMSlow') % (-) early - TM slow
%                         regressorNames{1} = 'Adapt';
%                         
%                         [~,~,~,Data{2},~] = adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(7,:),fh,ph(1,2),epSession2(8,:),flip); % Noadapt (env-driven/within-env), - EMGon(+) = TM base - EMG_on(+)
%                         title('Multi-Env-Switch: TMfast-PosShort')
%                         regressorNames{2} = 'Noadapt';
%                     end
%                     [~,~,~,Data{3},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(1,:),fh,ph(1,3),ep(5,:),flip); %  -(TR base - OG base) = OG base - TR base (NIM base), env switching
%                     title('Env-Switch: OG-OGNimbus')  % OG - OGNimbus
%                     regModelVersion = 'default'
%                     
%                     [~,~,~,Data{4},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,Post1Early,fh,ph(1,4),AdaptLate,flip); %OGafter - Adaptation_{SS} , transition 1
%                     title('Transition 1')
%                     
%                     [~,~,~,Data{5},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,Post2Early,fh,ph(1,5),Post1Late,flip); %Nimbus post early - OG post late, transition 2
%                     title('Transition 2')
%                     
%                     [~,~,~,Data{6},~] = adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,OGpostPosEarly,fh,ph(1,6),PosShort,flip); % OGpost Pos - Pos Short
%                     title('Transition 3: Short Split')
%                     
%                     
%                 else
%                     %                 'Adapt', 'WithinContextSwitch', 'MultiContextSwitch',
%                     regressorNames = {'MultiContextAdapt','EnvTransition','MultiContextSwitch','Trans1','Trans2','Trans3'};
%                     if (contains(groupID, 'NTS'))
%                         regModelVersion = 'TS'
%                     elseif (contains(groupID, 'NTR'))
%                         regModelVersion = 'TR'
%                     end
%                     switch splitCount
%                         case {1} %env switch use OGnoNimbus - OGNimbus
%                             [~,~,~,Data{1},~] =adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(12,:),fh,ph(1,1),epSession2(11,:),flip); % adapt
%                             title('Within-Env-Adapt: NegShort-TMSlow') % (-) early - TM slow
%                             regressorNames{1} = 'Adapt';
%                             
%                             [~,~,~,Data{2},~] = adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,epSession2(8,:),fh,ph(1,2),epSession2(9,:),flip); % MultiContextSwitch, TMfast - onPlusLate
%                             title('Multi-Env-Switch: TMfast-PosShort')
%                             regressorNames{2} = 'WithinContextSwitch';
%                             
%                             [~,~,~,Data{3},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(1,:),fh,ph(1,3),ep(8,:),flip);
%                             title('Env-Switch: OG-OGNimbus')  % OG - OGNimbus
%                             regModelVersion = 'default'
%                     end
%                     
%                 end
%                 [~,~,~,Data{4},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,Post1Early,fh,ph(1,4),AdaptLate,flip); %Post1 early - Adaptation_{SS} , transition 1
%                 title('Transition 1')
%                 [~,~,~,Data{5},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,Post2Early,fh,ph(1,5),Post1Late,flip); %Post2 early - Post 1 late, transition 2
%                 title('Transition 2')
%                 
%                 [~,~,~,Data{6},~] = adaptDataSubjectSession2.plotCheckerboards(newLabelPrefix,OGpostPosEarly,fh,ph(1,6),PosShort,flip); % OGpost Pos - Pos Short
%                 title('Transition 3: Short Split')
%                        
%             end
%             
%             set(ph(:,1),'CLim',[-1 1]*1.5);
%             set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1.5);
%             set(ph,'FontSize',8)
%             pos=get(ph(1,end),'Position');
%             axes(ph(1,end))
%             colorbar
%             set(ph(1,end),'Position',pos);
%             set(gcf,'color','w');
            
            nw=datestr(now,'yy-mm-dd');
            resDir = [scriptDir '/RegressionAnalysis/RegModelResults_', nw ,'/IndvResults/'];
            
            
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
%     end
  
% end

%%
% plot checkerboard per group
splitCount = 1
if ~length(subID) > 1 || plotGroup
    for flip = [1]
        summaryflag='nanmedian';
        %         summaryflag=[];
%         fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
%         ph=tight_subplot(1,6,[.03 .005],.04,.04);
        
        
        Data = {}; %in order: {'Adapt','WithinContextSwitch','MultiContextSwitch','Trans1','Trans2'};
        %                         [~,~,labels,dataE{1},dataRef{1}]=normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep,fh,ph(1,2:end),refEp,flip);%Second, the rest:
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
%             AdaptLate = defineReferenceEpoch('Adaptation',ep);
%             Post1Late= defineReferenceEpoch('Post1_{Late}',ep);
%             Post1Early= defineReferenceEpoch('Post1_{Early}',ep);
%             Post2Early=defineReferenceEpoch('Post2_{Early}',ep);
%             OGpostPosEarly=defineReferenceEpoch('OGAfterPost',epSession2);
%             PosShort=defineReferenceEpoch('PostShort',epSession2);
            
        else
            ep=defineEpochNIM_OG_UpdateV3('nanmean');
            %         multi env and transition 1 and 2 always use this, deltaAdapt and
            %         nonAdapt could be from this or the session2
            if ~isempty(session2subID)
                epSession2 = defineEpochNIM_NTR_Session2('nanmean', groupID);
            end
            %             refEpAdaptLate = defineReferenceEpoch('Task_{Switch}',ep);
            %             refEpOGpost= defineReferenceEpoch('Post1_{Late}',ep);
            
%             AdaptLate = defineReferenceEpoch('Adaptation',ep);
%             Post1Late= defineReferenceEpoch('Post1_{Late}',ep);
%             Post1Early= defineReferenceEpoch('Post1_{Early}',ep);
%             Post2Early=defineReferenceEpoch('Post2_{Early}',ep);
%             OGpostPosEarly=defineReferenceEpoch('OG 2',epSession2);
%             PosShort=defineReferenceEpoch('Pos short',epSession2);

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
        
           [Data,regressorNames]=RegressionsGeneralization(newLabelPrefix,normalizedTMFullAbrupt,session2Data,0,1,NegShort,TMbeforeNeg,PosShort,TMbeforePos,...
        AdaptLate,Post1Early,Post1Late,Post2Early, OGpostPosEarly, OGbase, EnvBase);
    
        
        
        
%         if ~Testing
%             
%             if splitCount == 1
%                 if usefft
%                     [~,~,labels,Data{1},dataRef2]=session2Data.plotCheckerboards(newLabelPrefix,epSession2(3,:),fh,ph(1,1),epSession2(14,:),flip,summaryflag); %  EMG_split(+) - TM base slow, adaptation, later will be leg swapped
%                 else
%                     [~,~,labels,Data{1},dataRef2]=session2Data.plotCheckerboards(newLabelPrefix,epSession2(11,:),fh,ph(1,1),epSession2(2,:),flip,summaryflag); %  EMG_split(-) - TM base slow, adaptation
%                 end
%                 d = nanmedian(Data{1}, 4);
%                 title(['Within-Env-Adapt: NegShort-TMSlow'] ,[ 'Norm=', num2str(norm(reshape(d,[],1)))]) % (-) early - TM slow
%                 regressorNames{1} = 'Adapt';
%                
%                 
%                 [~,~,~,Data{2},~] = session2Data.plotCheckerboards(newLabelPrefix,epSession2(7,:),fh,ph(1,2),epSession2(8,:),flip,summaryflag); % Noadapt (env-driven/within-env), - EMGon(+) = TM base - EMG_on(+)
%                 d = nanmedian(Data{2}, 4);
%                 title(['Multi-Env-Switch: TMfast-PosShort'] ,[ 'Norm=', num2str(norm(reshape(d,[],1)))])
%                 regressorNames{2} = 'WithinContextSwitch';
%                 
%             end
%             [~,~,~,Data{3},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(1,:),fh,ph(1,3),ep(6,:),flip,summaryflag); %  OG base - TR base = -(TR base - OG base), env switching
%             d = nanmedian(Data{3}, 4);
%             title(['Env-Switch: OG-OGNimbus'] ,[ 'Norm=', num2str(norm(reshape(d,[],1)))])  % OG - OGNimbus
%             regModelVersion = 'default'
%             
%             [~,~,~,Data{4},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,Post1Early,fh,ph(1,4),AdaptLate,flip,summaryflag); %OGafter - Adaptation_{SS}, transition 1
%             d = nanmedian(Data{4}, 4);
%             title(['Transition 1'] ,[ 'Norm=', num2str(norm(reshape(d,[],1)))])
%             
%             
%             [~,~,~,Data{5},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,Post2Early,fh,ph(1,5),Post1Late,flip,summaryflag); %TM post VR early - OG post late, transition 2
%             d = nanmedian(Data{5}, 4);
%             title(['Transition 2'] ,[ 'Norm=', num2str(norm(reshape(d,[],1)))])
%             
%             [~,~,~,Data{6},~] = session2Data.plotCheckerboards(newLabelPrefix,OGpostPosEarly,fh,ph(1,6),PosShort,flip,summaryflag); % OGpost Pos - Pos Short
%             d = nanmedian(Data{6}, 4);
%             title(['Transition 3: Short Split'] ,[ 'Norm=', num2str(norm(reshape(d,[],1)))])
%         else
%             %                 'Adapt', 'WithinContextSwitch', 'MultiContextSwitch',
%             epSession2 = defineEpochNimbusShoesTesting_Session2('nanmean');
%             ep=defineEpochNimbusShoes_longProtocol('nanmean');
%             
%             regressorNames = {'MultiContextAdapt','EnvTransition','MultiContextSwitch','Trans1','Trans2'};
%             if (contains(groupID, 'NTS'))
%                 regModelVersion = 'TS'
%             elseif (contains(groupID, 'NTR'))
%                 regModelVersion = 'TR'
%             end
%             switch splitCount
%                 case {1} %env switch use OGnoNimbus - OGNimbus
%                     
%                     %                         [~,~,~,Data{1},~] =normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(6,:),fh,ph(1,1),ep(5,:),flip); % adapt
%                     %                         title('Within-Env-Adapt: NegShort-TMSlow') % (-) early - TM slow
%                     %                         regressorNames{1} = 'WithinContextAdapt';
%                     %
%                     %                         [~,~,~,Data{2},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(2,:),fh,ph(1,2),ep(21,:),flip); % MultiContextSwitch, OG early - onPlusLate
%                     %                         title('Multi-Env-Switch: TMfast-PosShort_{late}')
%                     %                              regressorNames{2} = 'WithinContextSwitch';
%                     %
%                     %                         [~,~,~,Data{3},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(1,:),fh,ph(1,3),ep(8,:),flip);
%                     %                         title('Env-Switch: OG-OGNimbus')  % OG - TM fast
%                     %                         regModelVersion = 'default'
%                     %
%                     [~,~,~,Data{1},~] =session2Data.plotCheckerboards(newLabelPrefix,epSession2(12,:),fh,ph(1,1),epSession2(11,:),flip,summaryflag); % adapt
%                     d = nanmedian(Data{1}, 4);
%                     title(['Within-Env-Adapt: NegShort-TMSlow'] ,[ 'Norm=', num2str(norm(reshape(d,[],1)))]) % (-) early - TM slow
%                     regressorNames{1} = 'Adapt';
%                     
%                     [~,~,~,Data{2},~] = session2Data.plotCheckerboards(newLabelPrefix,epSession2(8,:),fh,ph(1,2),epSession2(9,:),flip,summaryflag); % MultiContextSwitch, TMfast - onPlusLate
%                     d = nanmedian(Data{2}, 4);
%                     title(['Multi-Env-Switch: TMfast-PosShort'] ,[ 'Norm=', num2str(norm(reshape(d,[],1)))])
%                     regressorNames{2} = 'WithinContextSwitch';
%                     
%                     [~,~,~,Data{3},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(1,:),fh,ph(1,3),ep(8,:),flip,summaryflag);
%                     d = nanmedian(Data{3}, 4);
%                     title(['Env-Switch: OG-OGNimbus'] ,[ 'Norm=', num2str(norm(reshape(d,[],1)))])  % OG - OGNimbus
%                     regModelVersion = 'default'
%                     
%             end
%             
%             %             [~,~,~,Data{4},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(10,:),fh,ph(1,4),ep(9,:),flip,summaryflag); %Post1 early - Adaptation_{SS} , transition 1
%             [~,~,~,Data{4},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,Post1Early,fh,ph(1,4),AdaptLate,flip,summaryflag);%Post1 early - Adaptation_{SS}, transition 1
%             d = nanmedian(Data{4}, 4);
%             title(['Transition 1'] ,[ 'Norm=', num2str(norm(reshape(d,[],1)))])
%             
%             %             [~,~,~,Data{5},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,ep(13,:),fh,ph(1,5),ep(12,:),flip,summaryflag); %Post2 early - Post 1 late, transition 2
%             [~,~,~,Data{5},~] = normalizedTMFullAbrupt.plotCheckerboards(newLabelPrefix,Post2Early,fh,ph(1,5),Post1Late,flip,summaryflag); %TM post VR early - OG post late, transition 2
%             d = nanmedian(Data{5}, 4);
%             title(['Transition 2'] ,[ 'Norm=', num2str(norm(reshape(d,[],1)))])
%             
%             [~,~,~,Data{6},~] = session2Data.plotCheckerboards(newLabelPrefix,OGpostPosEarly,fh,ph(1,6),PosShort,flip,summaryflag); %TM post VR early - OG post late, transition 2
%             d = nanmedian(Data{6}, 4);
%             title(['Transition 3: Short Split',] ,[ 'Norm=', num2str(norm(reshape(d,[],1)))])
%             
%             
%         end
%         
%         set(ph(:,1),'CLim',[-1 1]*1.5);
%         set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1.5);
%         set(ph,'FontSize',8)
%         pos=get(ph(1,end),'Position');
%         axes(ph(1,end))
%         colorbar
%         set(ph(1,end),'Position',pos);    
%         set(gcf,'color','w');

         nw=datestr(now,'yy-mm-dd');
%          ['allDataRedAlt_BootStrap_',num2str(n) ,'_', nw '.mat']
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
            
            %             if session == 1
            %                 adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(7,:),fh,ph(1,8),refEpLate,flip);%plot the Post1-AdaptSS epoch
            %             else
            %                 adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(9:end,:),fh,ph(1,end-2:end),[],flip);%plot the Post1-AdaptSS epoch
            %             end
            
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
        
        if (contains(groupID, 'NTS'))%correct post 1 with OG no nimbus, post 2 with OG with nimbus, i.e.,TR
            adaptDataSubject.plotCheckerboards(newLabelPrefix,post1ep,fh,ph(1,3),refEpOG,flip); %post1 is OG
            adaptDataSubject.plotCheckerboards(newLabelPrefix,post2ep,fh,ph(1,4),refEpTR,flip); %post2 is with Nimbus(TR)
            adaptDataSubject.plotCheckerboards(newLabelPrefix,post1lateep,fh,ph(1,5),refEpOG,flip);
            adaptDataSubject.plotCheckerboards(newLabelPrefix,post2lateep,fh,ph(1,6),refEpTR,flip);
            
        elseif (contains(groupID, 'NTR')) %correct post 1 with TR(nimbus), post 2 with OG (No nimbus)
            adaptDataSubject.plotCheckerboards(newLabelPrefix,post1ep,fh,ph(1,3),refEpTR,flip);
            adaptDataSubject.plotCheckerboards(newLabelPrefix,post2ep,fh,ph(1,4),refEpOG,flip);
            adaptDataSubject.plotCheckerboards(newLabelPrefix,post1lateep,fh,ph(1,5),refEpTR,flip);
            adaptDataSubject.plotCheckerboards(newLabelPrefix,post2lateep,fh,ph(1,6),refEpOG,flip);
        end
        
        %         adaptDataSubject.plotCheckerboards(newLabelPrefix,post1ep,fh,ph(1,3),[],flip);
        %         adaptDataSubject.plotCheckerboards(newLabelPrefix,post2ep,fh,ph(1,4),[],flip);
        %         adaptDataSubject.plotCheckerboards(newLabelPrefix,post1lateep,fh,ph(1,5),[],flip);
        %         adaptDataSubject.plotCheckerboards(newLabelPrefix,post2lateep,fh,ph(1,6),[],flip);
        %
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
%% EMG aftereffects

refEpPost1Early= defineReferenceEpoch('Post1_{Early}',ep);
if contains(groupID,'NTR')
    refEp= defineReferenceEpoch('OGNimbus',ep); %fast tied 1 if short split 1, slow tied if 2nd split
elseif contains(groupID,'NTS')
    refEp= defineReferenceEpoch('OGBase',ep);
end
fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
ph=tight_subplot(1,n_subjects+1,[.03 .005],.04,.04);
flip = [1];


% load(['IndivRegressionParams_',groupID,'.mat'])
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
    %     vec_norm = norm(Data{i+1});
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

%% Getting norm of epoch of interest
VarNames=[];
removeBias=1;
plotGroup=0;

if plotGroup==1
    l=1;
else
    l= 1:n_subjects;
end

if contains(groupID,'NTS')
    refEpTR = defineReferenceEpoch('BaseNoShoes',ep);
elseif contains(groupID,'NTR')
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
        ph=tight_subplot(1,12,[.03 .005],.04,.04);
        flip=true;
        
        %         [~,~,~,Data,~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpTR,fh,ph(1,1),[],flip); %plot TM tied 1 reference
        %         title({[refEpTR.Properties.ObsNames{1} '[' num2str(refEpTR.Stride_No(1)) ']'] ['Norm=', num2str(norm(Data))]});
        %         norData=norm(Data);
        %         VarNames{1,1}= refEpTR.Properties.ObsNames{1};
        %         VarNames{1,i+1}=norData;
        
        
        if contains(groupID,'NTS')
            refEpTR = defineReferenceEpoch('BaseNoShoes',ep);
            
            [~,~,~,Data,~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpTR,fh,ph(1,1),[],flip); %plot TM tied 1 reference
            Data = Data(~isnan(Data));
            title({[refEpTR.Properties.ObsNames{1} '[' num2str(refEpTR.Stride_No(1)) ']'] ['Norm=', num2str(norm(Data))]});
            norData=norm(Data);
            VarNames{1,1}= refEpTR.Properties.ObsNames{1};
            VarNames{1,i+1}=norData;
            
            
            for ii=1:6
                [~,~,~,Data,~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(ii,:),fh,ph(1,ii+1),bias,flip);%plot all epochs normalized by the fast baseline
                Data = Data(~isnan(Data));
                norData=norm(Data);
                title({[ep.Properties.ObsNames{ii} '[' num2str(ep.Stride_No(ii)) ']'] ['Norm=', num2str(norData)]});
                VarNames{ii+1,1}= ep.Properties.ObsNames{ii};
                VarNames{ii+1,i+1}=norData;
            end
            
            [~,~,~,Data,~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(10,:),fh,ph(1,8),refEpLate,flip);%plot the early Post - late Ada block
            Data = Data(~isnan(Data));
            title({[ep.Properties.ObsNames{10} '[' num2str(ep.Stride_No(9)) ']'] ['Norm=', num2str(norm(Data))]});
            norData=norm(Data);
            VarNames{8,1}= ep.Properties.ObsNames{7};
            VarNames{8,i+1}=norData;
            
            for ii=[8 9 11]
                [~,~,~,Data,~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(ii,:),fh,ph(1,ii+1),bias,flip);%plot all remaining epochs normalized by the fast baseline
                Data = Data(~isnan(Data));
                norData=norm(Data);
                title({[ep.Properties.ObsNames{ii} '[' num2str(ep.Stride_No(ii)) ']'] ['Norm=', num2str(norData)]});
                VarNames{ii+1,1}= ep.Properties.ObsNames{ii};
                VarNames{ii+1,i+1}=norData;
            end
            
            for ii=[10]
                [~,~,~,Data,~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(ii,:),fh,ph(1,ii+1),ep(9,:),flip);%plot all remaining epochs normalized by the fast baseline
                Data = Data(~isnan(Data));
                norData=norm(Data);
                title({[ep.Properties.ObsNames{ii} '[' num2str(ep.Stride_No(ii)) ']'] ['Norm=', num2str(norData)]});
                VarNames{ii+1,1}= ep.Properties.ObsNames{ii};
                VarNames{ii+1,i+1}=norData;
            end
            
        elseif contains(groupID,'NTR')
            
            [~,~,~,Data,~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,refEpTR,fh,ph(1,1),[],flip); %plot TM tied 1 reference
            Data = Data(~isnan(Data));
            title({[refEpTR.Properties.ObsNames{1} '[' num2str(refEpTR.Stride_No(1)) ']'] ['Norm=', num2str(norm(Data))]});
            norData=norm(Data);
            VarNames{1,1}= refEpTR.Properties.ObsNames{1};
            VarNames{1,i+1}=norData;
            
            
            for ii=[1:2 5:6]
                [~,~,~,Data,~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(ii,:),fh,ph(1,ii+1),bias,flip);%plot all epochs normalized by the fast baseline
                Data = Data(~isnan(Data));
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
                Data = Data(~isnan(Data));
                title({[epSession2.Properties.ObsNames{ii} '[' num2str(epSession2.Stride_No(ii)) ']'] ['Norm=', num2str(norm(Data))]});
                norData=norm(Data);
                VarNames{p(r),1}= epSession2.Properties.ObsNames{ii};
                VarNames{p(r),i+1}=norData;
            end
            
            
            [~,~,~,Data,~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(7,:),fh,ph(1,8),refEpLate,flip);%plot the early Post - late Ada block
            
            Data = Data(~isnan(Data));
            title({[ep.Properties.ObsNames{7} '[' num2str(ep.Stride_No(9)) ']'] ['Norm=', num2str(norm(Data))]});
            norData=norm(Data);
            VarNames{8,1}= ep.Properties.ObsNames{7};
            VarNames{8,i+1}=norData;
            
            
            for ii=[8 9 11]
                [~,~,~,Data,~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(ii,:),fh,ph(1,ii+1),bias,flip);%plot all remaining epochs normalized by the fast baseline
                Data = Data(~isnan(Data));
                norData=norm(Data);
                title({[ep.Properties.ObsNames{ii} '[' num2str(ep.Stride_No(ii)) ']'] ['Norm=', num2str(norData)]});
                VarNames{ii+1,1}= ep.Properties.ObsNames{ii};
                VarNames{ii+1,i+1}=norData;
            end
            
            for ii=[10]
                [~,~,~,Data,~]= adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(ii,:),fh,ph(1,ii+1),ep(9,:),flip);%plot all remaining epochs normalized by the fast baseline
                Data = Data(~isnan(Data));
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
    save(['GNorm_', groupID,'_', num2str(removeBias)], 'GroupTable')
else
    IndvTable = cell2table([VarNames],'VariableNames',{'Epoch',subID{:}});
    meanTable = array2table( nanmean(cell2mat(VarNames(:,2:end)),2),'VariableNames',convertCharsToStrings(groupID));
    save(['Norm_', groupID,'_', num2str(removeBias)], 'IndvTable', 'meanTable')
end


