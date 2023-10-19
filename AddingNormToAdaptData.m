%% Adding Norm to groupAdaptationData

% Load data and Find norms for the entire time courses
%This code will find Euclidean norms for the entire time courses
%Created by DMM0 5/2022 - Update by DMMO Oct 2023

% 1) load subjects
% 2) EMG normalization of baseline
% 3) Remove bad muscles making then zero. We are computing the norm
% 4) Computing Stride by stride norm
% 5) Compute bias removed stride by stride norm
% 6) Saving params file 

%% Define conditions
saveData=1 %if you want to save your data 
%% load subjects  and prep data (Step 1 and 2)

% clear; clc; %close all
groupID = {'C3'};
scriptDir = cd;
[normalizedGroupData, newLabelPrefix,n_subjects,subID]=creatingGroupdataWnormalizedEMG(groupID{1});
removeMuscles=1;
%% Removing bad muscles (Step 3) 
%This script make sure that we always remove the same muscle for the
%different analysis
if removeMuscles==1
    normalizedGroupData= RemovingBadMuscleToSubj(normalizedGroupData);
end

%% Norm Stride by Stride (Step 4)

for idx = 1:numel(subID)
    data=[];
    temp=[];
    aux1=[];
    
    subjIdx = find(contains(normalizedGroupData.ID, subID{idx}));

    
    
    
    if ~isempty(subjIdx)
        
        Subj = normalizedGroupData.adaptData{subjIdx};

        
        for i = 1:numel(newLabelPrefix)
            DataIdx=find(cellfun(@(x) ~isempty(x),regexp(Subj.data.labels,['^' newLabelPrefix{i} '[ ]?\d+$'])));
            
            data=[data Subj.data.Data(:,DataIdx)];
            data(isnan(data))=0;

        end
        
        data(isnan(data))=0;
        dataAsym=data-fftshift(data,2);
        dataAsym=dataAsym(:,1:size(dataAsym,2)/2,:);
        temp(:,1)=vecnorm(data');
        temp(:,2)=vecnorm(dataAsym');
        aux1=find(temp(:,1)>50);
        temp(aux1,:)=nan;
        normalizedGroupData.adaptData{idx}.data=normalizedGroupData.adaptData{idx}.data.appendData(temp,{'NormEMG','NormEMGasym'},...
            {'Norm of all the muscles','Norm asym of all the muscles'});
    end
    
    
    
end

%% Removing Bias (Step 5)

if contains(groupID,'NTS') ||  contains(groupID,'NTR') ||  contains(groupID,'CTR') || contains(groupID,'CTS')
    ep=defineEpochVR_OG_UpdateV8('nanmean');
    refEpTR= defineReferenceEpoch('TRbase',ep);
    refEpOG= defineReferenceEpoch('OGbase',ep);
else
    ep=defineEpochs_regressionYA('nanmean');
    refEpTR= defineReferenceEpoch('TM base',ep);
    refEpOG= defineReferenceEpoch('OG base',ep);
end

padWithNaNFlag=true;

[OGref]=normalizedGroupData.getPrefixedEpochData(newLabelPrefix,refEpOG,padWithNaNFlag); 
OGref=squeeze(OGref);
OGrefasym=OGref-fftshift(OGref,1);
OGrefasym=OGref(1:size(OGref,1)/2,:,:);

[TRref]=normalizedGroupData.getPrefixedEpochData(newLabelPrefix,refEpTR,padWithNaNFlag); 
TRref=squeeze(TRref);
TRrefasym=TRref-fftshift(TRref,1);
TRrefasym=TRref(1:size(TRref,1)/2,:,:);

for idx = 1:numel(subID)
    data=[];
    temp=[];
    data3=[];
    data3asym=[];

    subjIdx = find(contains(normalizedGroupData.ID, subID{idx}));

    
    
    if ~isempty(subjIdx)
        
        Subj = normalizedGroupData.adaptData{subjIdx};

        
        for i = 1:numel(newLabelPrefix)
            DataIdx=find(cellfun(@(x) ~isempty(x),regexp(Subj.data.labels,['^' newLabelPrefix{i} '[ ]?\d+$'])));            
                        
            data=[data Subj.data.Data(:,DataIdx)];
            data(isnan(data))=0;

        end    
        trial=find(contains(Subj.data.labels, {'trial'}));
        tt=unique(Subj.data.Data(:,trial));
        for t=1:length(tt)
            zz=tt(t);
            aux2=[];
            aux3=[];
            if find(contains(Subj.data.trialTypes(zz), {'OG'} ))
                
                Idx = find(Subj.data.Data(:,trial)==zz);
                aux2=data(Idx,:)';
                data2= aux2-OGref(:,subjIdx);
                
                aux3=aux2-fftshift(aux2,1);
                aux3=aux3(1:size(aux3,1)/2,:,:);
                
                data2asym=aux3-OGrefasym(:,subjIdx);
                
                
                
                
                
            else
                
                Idx = find(Subj.data.Data(:,trial)==zz);
                aux2=data(Idx,:)';
                data2= aux2-TRref(:,subjIdx);
                
                aux3=aux2-fftshift(aux2,1);
                aux3=aux3(1:size(aux3,1)/2,:,:);
                
                data2asym=aux3-TRrefasym(:,subjIdx);
                
                
            end
   
            data3=[data3 data2];
            data3asym=[data3asym data2asym];
            
        end
        data3(isnan(data3))=0;
        data3asym(isnan(data3asym))=0;
        temp(:,1)=vecnorm(data3);
        temp(:,2)=vecnorm(data3asym);
        aux1=find(temp(:,1)>50);
        temp(aux1,:)=nan;
        aux1=normalizedGroupData.adaptData{idx}.data.Data;
        normalizedGroupData.adaptData{idx}.data=normalizedGroupData.adaptData{idx}.data.appendData(temp,{'UnBiasNormEMG','UnBiasNormEMGasym'},{'Context specifci unbais Norm of all the muscles','Context specifci unbais Norm asym of all the muscles'});
    end
    
    
    
end

%% SAVE GROUP DATA (Step 6)

    group= normalizedGroupData;

if saveData==1
    save([groupID{1}, '_EMGnorm.mat'], 'group')
end

%%  This section is to plot the results

group2=[];
group2{1}=group;


conditions = {'OG base','TM base','Adaptation',...
    'Post 1','Post 2'};


params={'netContributionNorm2','NormEMG'};
poster_colors;
colorOrder=[p_red; p_orange; p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0];[0 1 1]];
     
binwidth=5; %Window of the running average
trialMarkerFlag=0; %1 if you want to separete the time course by trial 0 to separece by condition 
indivFlag=1; %0 to plot group mean 1 to plot indiv subjects
indivSubs=[]; %Use when you want to plot a specidfic subject in a group 
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
% legend('AutoUpdate','off')
% yline(0)

% yline(nanmean(avg.NormEMGasym.TMbase.trial1(1,end-15:end)))