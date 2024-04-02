%% Adding Norm to groupAdaptationData

% Load data and Find norms for the entire time courses
%This code will find Euclidean norms for the entire time courses
%Created by DMM0 5/2022

%Modified 4/2024 DMMO

% 1) load subjects
% 2) EMG normalization of baseline
% 3) Remove bad muscles making then zero. We are computing the norm
% 4) Computing Stride by stride norm
% 5) Compute bias removed stride by stride norm
% 6) Saving params file 


% TO DO: The code only gets the indiviudal muscle norm value we needs to implement: 
%1) Indivual muscle asymmetry 
%2) Removing the bias per muscle 

%% load subjects
clear; clc; close all

% set script parameters, SHOULD CHANGE/CHECK THIS EVERY TIME.

groupID ='BAT'; %Group of interest 
[group, newLabelPrefix,n,subID]=creatingGroupdataWnormalizedEMG(groupID,1,[]); % Creating the groupData normalized

%% Removing bad muscles 
%This script make sure that we always remove the same muscle for the
%different analysis 
removeBadmuscles=1;
if removeBadmuscles==1
group= RemovingBadMuscleToSubj(group);
end

%% Norm Stride by Stride 
label=strcat(newLabelPrefix,'Norm');
desc=strcat(strcat(strcat(label,' muscle during the full gait cycle')));

for idx = 1:numel(subID)
    data=[];
    temp=[];
%     aux1=[];
    
    subjIdx = find(contains(group.ID, subID{idx}));

    if ~isempty(subjIdx)
        
        Subj = group.adaptData{subjIdx};
        
        
        for i = 1:numel(newLabelPrefix)
            
            DataIdx=find(cellfun(@(x) ~isempty(x),regexp(Subj.data.labels,['^' newLabelPrefix{i} '[ ]?\d+$'])));
           
            data=[Subj.data.Data(:,DataIdx)];
            data(isnan(data))=0;
            
            
            data(isnan(data))=0;
%             dataAsym=data-fftshift(data,2);
%             dataAsym=dataAsym(:,1:size(dataAsym,2)/2,:);
            temp(:,i)=vecnorm(data');
%             temp2(:,i)=vecnorm(dataAsym');
%             aux1=find(temp(:,1)>50);
%             temp(aux1,:)=nan;
        end
        
        group.adaptData{idx}.data=group.adaptData{idx}.data.appendData(temp,label,...
            desc);
    end
  
end

%% % Removing Bias (TO DO)
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

%Turn on if you want to safe your data. 

% if contains(groupID,'NTS')
%     
    group2{1}= group;
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

%% Plotting examples 

params={'fMGsNorm';'sMGsNorm'};
poster_colors;
colorOrder=[p_orange;p_red; p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0];[0 1 1]];
  conditions= {'TM slow','TM fast','TM base','Adaptation','Post 1'}; 
binwidth=5; %Window of the running average
trialMarkerFlag=0; %1 if you want to separete the time course by trial 0 to separece by condition 
indivFlag=0; %0 to plot group mean 1 to plot indiv subjects','singleStanceSpeedDiffAbsAnk'
indivSubs=[];%{{'C3S01','C3S02_S1','C3S03_S1','C3S05_S1','C3S06_S1','C3S07_S1'},{'AUF19V02','AUF10V02','AUF06V02','AUF20V02','AUF16V02','AUF21V02'}}; %Use when you want to plot a specidfic subject in a group 
% colorOrder=[];%[p_red; p_orange; p_plum;p_fade_green]; %Let the function take care of this at least you wanted in a specific set of color then by my guess and add the list here
biofeedback= 0; % At least that you are providing with biofeedback to the subject
removeBiasFlag=0; %if you want to remove bias 
%%Groups names 
labels=[];
filterFlag=[]; 
% figure 
% p=subplot(1,1,1);
plotHandles=[];
alignEnd=0; % # strides align at the end of the trial (PLAY with it as see what happens)
alignIni=0; %  # strides align at the beginning of the trial (PLAY with it as see what happens) 

adaptData=cellfun(@(x) x.adaptData,group2,'UniformOutput',false); %Notice that adaptDataGroups(1) decide that I only want to plot the CG group 
[figh,avg,indv]=adaptationData.plotAvgTimeCourse(adaptData,params,conditions,binwidth,trialMarkerFlag,...
    indivFlag,indivSubs,colorOrder,biofeedback,removeBiasFlag,labels,filterFlag,plotHandles,alignEnd,alignIni);
