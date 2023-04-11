%% Adding Norm to groupAdaptationData

% Load data and Find norms for the entire time courses
%This code will find Euclidean norms for the entire time courses
%Created by DMM0 5/2022

% 1) load subjects
% 2) EMG normalization of baseline
% 3) Remove bad muscles making then zero. We are computing the norm
% 4) Computing Stride by stride norm
% 5) Compute bias removed stride by stride norm
% 6) Saving params file 


%% load subjects

clear; clc; close all

% set script parameters, SHOULD CHANGE/CHECK THIS EVERY TIME.
groupID = 'BATR';
saveResAndFigure = false;
plotAllEpoch = true;
plotIndSubjects = true;
plotGroup = false;
kinenatics=false;

scriptDir = cd;
files = dir ([scriptDir '/' groupID '*params.mat']);
norms=[];
norm1 = [];
norm2 = [];

n_subjects = size(files,1);
subID = cell(1, n_subjects);
sub=cell(1,n_subjects);

for i = 1:n_subjects

    sub{i} = files(i).name; %for plotting group
    if kinenatics==0
        subID{i} = sub{i}(1:end-10);
    else
        subID{i} = sub{i}(1:end-14);
    end
end
subID

regModelVersion =  'default'; %'default'



%% 1: load and prep data

normalizedTMFullAbrupt=adaptationData.createGroupAdaptData(sub);
% normalizedTMFullAbrupt=normalizedTMFullAbrupt.removeBadStrides; % we are
% going to add the EMGnorm for all strides we can't removeBadStrides 


subjectsToPlot = {}; % from SLcode
subjectsToPlotID = {}; % from SLcode
subjectsToPlotResDirs = {}; % from SLcode

% subjectsToPlot{end+1} = normalizedTMFullAbrupt; % from SLcode
% subjectsToPlotID{end+1} = groupID;% from SLcode
%subjectsToPlotResDirs{end+1} = resDir{end};% from SLcode

muscleOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'HIP'};

% muscleOrder={'TA'};
n_muscles = length(muscleOrder);

n_subjects = length(subID);


if contains(groupID,'NTS') ||  contains(groupID,'NTR') ||  contains(groupID,'CTR') || contains(groupID,'CTS')
ep=defineEpochVR_OG_UpdateV8('nanmean');
% if contains(groupID,'TR')
%     refEp= defineReferenceEpoch('TRbase',ep); %fast tied 1 if short split 1, slow tied if 2nd split %Use for NTR and CTR
% elseif contains(groupID,'TS')
refEp= defineReferenceEpoch('OGbase',ep); %fast tied 1 if short split 1, slow tied if 2nd split %Use for NTS and CTS
% end
else
ep=defineEpochs_regressionYA('nanmean');  
refEp= defineReferenceEpoch('TM base',ep); 
    
end
newLabelPrefix = defineMuscleList(muscleOrder);

normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,refEp); %Normalized by TM base (aka mid baseline)

ll=normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');
l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ll,l2);
newLabelPrefix = regexprep(newLabelPrefix,'_s','s');

subjectsToPlot{end+1} = normalizedTMFullAbrupt; % from SLcode
subjectsToPlotID{end+1} = groupID;% from SLcode

%% Remove aftereffects using Shuqi's code
% Bad muscles for group plots
% %NTS
% if contains(groupID,'NTS')
%     badSubjID = {'NTS_01', 'NTS_03', 'NTS_05','NTS_06','NTS_07'}; %badSubj and muscle are index matched, if want to remove group, put group ID here
%     badMuscles = {{'sHIPs', 'fHIPs','fSEMTs','sSEMTs'},{'sLGs', 'fLGs'},{'sBFs', 'fBFs','fVLs','sVLs','fVMs','sVMs'},{'sHIPs','fHIPs','sSOLs','fSOLs'},{'fRFs','sRFs'}}; %labels in group ID will be removed for all regression and AE computations;
% 
% elseif contains(groupID,'NTR')
%     %NTR
%     badSubjID = {'NTR_01','NTR_03','NTR_04'}; %badSubj and muscle are index matched, if want to remove group, put group ID here
%     badMuscles = {{'fVLs','sVLs','sVMs','fVMs'},{'fRFs','sRFs'},{'sLGs','fLGs','sRFs','fRFs'}}; %labels in group ID will be removed for all regression and AE computations;
% 
% elseif contains(groupID,'CTR')
%     % %CTR
%     badSubjID = {'CTR_02','CTR_05'}; %badSubj and muscle are index matched, if want to remove group, put group ID here
%     badMuscles = {{'sTFLs', 'fTFLs','fPERs','sPERs','fTAs','sTAs','sRFs','fRFs'},{'sHIPs', 'fHIPs','sPERs','fPERs'}}; %labels in group ID will be removed for all regression and AE computations;
% 
% elseif contains(groupID,'CTS')
%     % %CTS
%     badSubjID = {'CTS_03','CTS_04','CTS_05','CTS_06'}; %badSubj and muscle are index matched, if want to remove group, put group ID here
%     badMuscles = {{'sHIPs','fHIPs'},{'sLGs', 'fLGs'},{'sLGs', 'fLGs'},{'sTAs', 'fTAs','fHIPs','sHIPs'}}; %labels in group ID will be removed for all regression and AE computations;
% 
% 
% elseif contains(groupID,'AUF')
%     badSubjID = {'AUF03V02', 'AUF03V04', 'AUF03V03','AUF04V03','AUF04V02'}; %badSubj and muscle are index matched, if want to remove group, put group ID here
% badMuscles = {{'fMGs','sHIPs'},{'fMGs','sHIPs'},{'fMGs','sHIPs'},{'fBFs','fHIPs'},{'fRFs'}}; %labels in group ID will be removed for all regression and AE computations;
% 
% 
% 
% elseif contains(groupID,'ATS')
%     badSubjID = {'ATS08'}; %badSubj and muscle are index matched, if want to remove group, put group ID here
% badMuscles = {{'fHIPs','sHIPs','fRFs','sRFs'}}; %labels in group ID will be removed for all regression and AE computations;
% 
% elseif contains(groupID,'ATR')
%     badSubjID = {'ATR04'}; %badSubj and muscle are index matched, if want to remove group, put group ID here
% badMuscles = {{'fHIPs','sHIPs'}}; %labels in group ID will be removed for all regression and AE computations;
% 
% 
% else
%     
% badSubjID = [];
% end
%ATR
% badSubjID = {'ATR01','ATR02','ATR03','ATR04'}; %badSubj and muscle are index matched, if want to remove group, put group ID here
% badMuscles = {{'sHIPs', 'fHIPs'},{'sRFs', 'fRFs','sVLs','fVLs'},{'sSEMTs','fSEMTs'},{'sHIPs','fHIPs','sRFs', 'fRFs'}}; %labels in group ID will be removed for all regression and AE computations;
%
% badSubjID = {'ATS01','ATR02','ATR03','ATR04'}; %badSubj and muscle are index matched, if want to remove group, put group ID here
% badMuscles = {{'sRFs', 'fRFs'},{'sRFs', 'fRFs','sVLs','fVLs'},{'sSEMTs','fSEMTs'},{'sHIPs','fHIPs'}}; %labels in group ID will be removed for all regression and AE computations;


%
% symmetricLabelPrefix = repmat({newLabelPrefix},length(files),1);
% newLabelPrefixPerSubj = repmat({newLabelPrefix},length(files),1);
% if ~isempty(badSubjID)
%     for idxToRemove = 1:numel(badSubjID)
%         
%         %     for j = 1: %possibly loop through all subjects with iteration j?
%         subjIdx = find(contains(subjectsToPlot{end}.ID, badSubjID{idxToRemove}));
%         %subjIdx = find(contains(sub,(badSubjID{idxToRemove})));
%         
%         %subjIdx = find(strcmp(files.name, badSubjID{idxToRemove}));
%         %          subjIdx = find(strcmp(badSubjID{idxToRemove},files.name));
%         %          subjIdx = find(contains(subjectsToPlot{end}.ID, badSubjID{idxToRemove}));
%         
%         
%         
%         if ~isempty(subjIdx)
%             
%             badSubj = normalizedTMFullAbrupt.adaptData{subjIdx};
%             %badSubj = sub.adaptData{subjIdx};
%             
%             for i = 1:numel(badMuscles{idxToRemove})
%                 
%                 badDataIdx=find(contains(badSubj.data.labels, {[badMuscles{idxToRemove}{i}, ' ']}));
%                 if length(badDataIdx)<12
%                     badDataIdxl ast=badDataIdx(end)+[1:3];
%                     badDataIdx= [badDataIdx; badDataIdxlast'];
%                 end
%                 %badDataIdx=find(contains(adaptData.data.labels, {[badMuscles{idxToRemove}{i}]}));
%                 
%                 badSubj.data.Data(:,badDataIdx) = 0;
%                 %adaptData.data.Data(:,badDataIdx) = nan;
%                 
%                 disp(['Removing (Setting zeros) of ' badMuscles{idxToRemove}{i} ' from Subject: ' badSubj.subData.ID])
%                 % disp(['Removing (Setting NaN) of ' badMuscles{idxToRemove}{i} ' from Subject: ' adaptData.subData.ID])
%                 
%             end
%             normalizedTMFullAbrupt.adaptData{subjIdx} = badSubj;
%         end
%         
%         
%         
%         
%     end
% end
%% Norm Stride by Stride 
label=strcat(newLabelPrefix,'Norm');
desc=strcat(strcat(strcat(label,' muscle during stance')));

for idx = 1:numel(subID)
    data=[];
    temp=[];
    aux1=[];
    
    subjIdx = find(contains(normalizedTMFullAbrupt.ID, subID{idx}));

    
    
    
    if ~isempty(subjIdx)
        
        Subj = normalizedTMFullAbrupt.adaptData{subjIdx};

        
        for i = 1:numel(newLabelPrefix)
            
            DataIdx=find(contains(Subj.data.labels, {[newLabelPrefix{i}, ' ']}));
            if length(DataIdx)<12
                DataIdxlast=DataIdx(end)+[1:3];
                DataIdx= [DataIdx; DataIdxlast'];
            end

            
            data=[Subj.data.Data(:,DataIdx)];
            data(isnan(data))=0;

       
        
        %         subjectsToPlot{end}.adaptData{subjIdx} = badSubj;
        data(isnan(data))=0;
        dataAsym=data-fftshift(data,2);
        dataAsym=dataAsym(:,1:size(dataAsym,2)/2,:);
        temp(:,i)=vecnorm(data');
%         temp(:,i)=vecnorm(dataAsym');
        aux1=find(temp(:,1)>50);
        temp(aux1,:)=nan;
         end
        normalizedTMFullAbrupt.adaptData{idx}.data=normalizedTMFullAbrupt.adaptData{idx}.data.appendData(temp,label,...
            desc);
    end
    
    
    
end

% %% Removing Bias 
% 
% if contains(groupID,'NTS') ||  contains(groupID,'NTR') ||  contains(groupID,'CTR') || contains(groupID,'CTS')
%     ep=defineEpochVR_OG_UpdateV8('nanmean');
%     refEpTR= defineReferenceEpoch('TRbase',ep);
%     refEpOG= defineReferenceEpoch('OGbase',ep);
% else
%     ep=defineEpochs_regressionYA('nanmean');
%     refEpTR= defineReferenceEpoch('TM base',ep);
%     refEpOG= defineReferenceEpoch('OG base',ep);
% end
% 
% padWithNaNFlag=true;
% 
% [OGref]=normalizedTMFullAbrupt.getPrefixedEpochData(newLabelPrefix,refEpOG,padWithNaNFlag); 
% OGref=squeeze(OGref);
% OGrefasym=OGref-fftshift(OGref,1);
% OGrefasym=OGref(1:size(OGref,1)/2,:,:);
% 
% [TRref]=normalizedTMFullAbrupt.getPrefixedEpochData(newLabelPrefix,refEpTR,padWithNaNFlag); 
% TRref=squeeze(TRref);
% TRrefasym=TRref-fftshift(TRref,1);
% TRrefasym=TRref(1:size(TRref,1)/2,:,:);
% 
% for idx = 1:numel(subID)
%     data=[];
%     temp=[];
%     data3=[];
%     data3asym=[];
% 
%     subjIdx = find(contains(normalizedTMFullAbrupt.ID, subID{idx}));
% 
%     
%     
%     if ~isempty(subjIdx)
%         
%         Subj = normalizedTMFullAbrupt.adaptData{subjIdx};
% 
%         
%         for i = 1:numel(newLabelPrefix)
%             
%             DataIdx=find(contains(Subj.data.labels, {[newLabelPrefix{i}, ' ']}));
%             if length(DataIdx)<12
%                 DataIdxlast=DataIdx(end)+[1:3];
%                 DataIdx= [DataIdx; DataIdxlast'];
%             end
%             
%                         
%             data=[data Subj.data.Data(:,DataIdx)];
%             data(isnan(data))=0;
% 
%         end    
%         %         subjectsToPlot{end}.adaptData{subjIdx} = badSubj;
%         trial=find(contains(Subj.data.labels, {'trial'}));
%         tt=unique(Subj.data.Data(:,trial));
%         for t=1:length(tt)
%             zz=tt(t);
%             aux2=[];
%             aux3=[];
%             if find(contains(Subj.data.trialTypes(zz), {'OG'} ))
%                 
%                 Idx = find(Subj.data.Data(:,trial)==zz);
%                 aux2=data(Idx,:)';
%                 data2= aux2-OGref(:,subjIdx);
%                 
%                 aux3=aux2-fftshift(aux2,1);
%                 aux3=aux3(1:size(aux3,1)/2,:,:);
%                 
%                 data2asym=aux3-OGrefasym(:,subjIdx);
%                 
%                 
%                 
%                 
%                 
%             else
%                 
%                 Idx = find(Subj.data.Data(:,trial)==zz);
%                 aux2=data(Idx,:)';
%                 data2= aux2-TRref(:,subjIdx);
%                 
%                 aux3=aux2-fftshift(aux2,1);
%                 aux3=aux3(1:size(aux3,1)/2,:,:);
%                 
%                 data2asym=aux3-TRrefasym(:,subjIdx);
%                 
%                 
%             end
%             
%             %                 trialidx=
%             
%             
%             
%             data3=[data3 data2];
%             data3asym=[data3asym data2asym];
%             
%         end
%         data3(isnan(data3))=0;
%         data3asym(isnan(data3asym))=0;
%         temp(:,1)=vecnorm(data3);
%         temp(:,2)=vecnorm(data3asym);
%         aux1=find(temp(:,1)>50);
%         temp(aux1,:)=nan;
%         aux1=normalizedTMFullAbrupt.adaptData{idx}.data.Data;
%         normalizedTMFullAbrupt.adaptData{idx}.data=normalizedTMFullAbrupt.adaptData{idx}.data.appendData(temp,{'UnBiasNormEMG','UnBiasNormEMGasym'},{'Context specifci unbais Norm of all the muscles','Context specifci unbais Norm asym of all the muscles'});
%     end
%     
%     
%     
% end

%% SAVE GROUP DATA 

% if contains(groupID,'NTS')
%     
    group= normalizedTMFullAbrupt;
%     
% elseif contains(groupID,'CTS')
%     
%     group = normalizedTMFullAbrupt;
%     
% elseif contains(groupID,'NTR')
%     
%     = normalizedTMFullAbrupt;
% elseif contains(groupID,'CTR')
%     
%     CTR= normalizedTMFullAbrupt;
% end

% save([groupID, '_EMGnorm.mat'], 'group')