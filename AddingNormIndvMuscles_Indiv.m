%% Adding Norm to adaptData

% Load data and Find norms for the entire time courses
%This code will find Euclidean norm at each step for the entire time courses
%Created by DMM0 5/10/2022

% 1) load subjects
% 2) EMG normalization of baseline
% 3) Computing Stride by stride norm
% 4) Compute bias removed stride by stride norm
% 5) Saving params file 

clear;clc; close all
%% 1: load and prep data
subID= 'BATR03';
load([subID, 'params.mat'])



%% 2:  EMG normalization of baseline


muscleOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'HIP'};
% muscleOrder={'TA','MG','PER'};
n_muscles = length(muscleOrder);

ep=defineEpochs_regressionYA('nanmean');
refEp= defineReferenceEpoch('TM base',ep);


newLabelPrefix = defineMuscleList(muscleOrder);

adaptData = adaptData.normalizeToBaselineEpoch(newLabelPrefix,refEp);

ll=adaptData.data.getLabelsThatMatch('^Norm');
l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
adaptData=adaptData.renameParams(ll,l2);
newLabelPrefix = regexprep(newLabelPrefix,'_s','s');


%% 2. Norm Stride by Stride

% Defining needed variables
data=[];
temp=[];
aux1=[];

Subj = adaptData; %Dummy variable


for i = 1:numel(newLabelPrefix) %loop on the all the muscles
    
     DataIdx=find(cellfun(@(x) ~isempty(x),regexp(Subj.data.labels,['^' newLabelPrefix{i} '[ ]?\d+$'])));
%     
%     DataIdx=find(contains(Subj.data.labels, {[newLabelPrefix{i}, ' ']})); %Find data index (row where the muscles are)
%     
%     if length(DataIdx)<12 % In case the code does not grab all the muscles
%         %(It should be 12 gaits phases of the gait cycle)
%         DataIdxlast=DataIdx(end)+[1:3];
%         DataIdx= [DataIdx; DataIdxlast'];
%     end
    
    
    data=[data Subj.data.Data(:,DataIdx)]; %Concatenating all the muscle data
    data(isnan(data))=0; % if nan set to zero the norm function cant work with nan
    
    data(isnan(data))=0;
    dataAsym=data-fftshift(data,2); % For asymmetry measure sustract the second part of the matrix
    dataAsym=dataAsym(:,1:size(dataAsym,2)/2,:); % Getting only the difference between legs
    temp(:,i)=vecnorm(data'); % getting the norm
    
end


% temp(:,2)=vecnorm(dataAsym'); % getting norm asymmetry value

%         aux1=find(temp(:,1)>50);
%         temp(aux1,:)=nan;
label=strcat(newLabelPrefix,'Norm');
desc=strcat(strcat(strcat(label,' muscle during stance')));
adaptData.data=adaptData.data.appendData(temp,label,...
   desc); % Adding parameter for to adaptData

%% 2. Norm Stride by Stride with baseline remove 

% ep=defineEpochs_regressionYA('nanmean'); %Define epochs of interest 
% refEpTR= defineReferenceEpoch('TM base',ep); % defining  Treadmill baseline 
% refEpOG= defineReferenceEpoch('OG base',ep);  % defining  overgounds baseline 
% 
% padWithNaNFlag=true; % Fill with Nan in case that we dont have enought strides
% 
% [OGref]=adaptData.getPrefixedEpochData(newLabelPrefix,refEpOG,padWithNaNFlag); % getting overgound baseline data
% OGref=squeeze(OGref); 
% OGrefasym=OGref-fftshift(OGref,1); % getting OG base for the asymmetry parameter 
% OGrefasym=OGref(1:size(OGref,1)/2,:,:);
% 
% [TRref]=adaptData.getPrefixedEpochData(newLabelPrefix,refEpTR,padWithNaNFlag); % getting treadmill baseline data
% TRref=squeeze(TRref);
% TRrefasym=TRref-fftshift(TRref,1);  % getting TM base for the asymmetry parameter 
% TRrefasym=TRref(1:size(TRref,1)/2,:,:);
% 
% %Defining needede dumy variables 
% data=[];
% temp=[];
% data3=[];
% data3asym=[];
% 
% Subj = adaptData;
% 
% 
% for i = 1:numel(newLabelPrefix) %loop on the all the muscles
%     
%     DataIdx=find(contains(Subj.data.labels, {[newLabelPrefix{i}, ' ']}));
%     if length(DataIdx)<12
%         DataIdxlast=DataIdx(end)+[1:3];
%         DataIdx= [DataIdx; DataIdxlast'];
%     end
%     
%     
%     data=[data Subj.data.Data(:,DataIdx)];
%     data(isnan(data))=0;
%     
% end
% 
% trial=find(contains(Subj.data.labels, {'trial'}));
% tt=unique(Subj.data.Data(:,trial));
% 
% for t=1:length(tt) % loop on all the trials 
%     
%     zz=tt(t);
%     aux2=[];
%     aux3=[];
%     
%     if find(contains(Subj.data.trialTypes(zz), {'OG'} )) %IF they are type OG remove OG baseline 
%         
%         Idx = find(Subj.data.Data(:,trial)==zz);
%         aux2=data(Idx,:)';
%         data2= aux2-OGref(:,1);
%         
%         aux3=aux2-fftshift(aux2,1); % For asymmetry measure sustract the second part of the matrix
%         aux3=aux3(1:size(aux3,1)/2,:,:);
%         
%         data2asym=aux3-OGrefasym(:,1);
% 
%         
%     else  %If they are type TM remove TM baseline 
%         
%         Idx = find(Subj.data.Data(:,trial)==zz);
%         aux2=data(Idx,:)';
%         data2= aux2-TRref(:,1);
%         
%         aux3=aux2-fftshift(aux2,1);% For asymmetry measure sustract the second part of the matrix
%         aux3=aux3(1:size(aux3,1)/2,:,:);
%         
%         data2asym=aux3-TRrefasym(:,1);
%         
%         
%     end
%     
% 
%     data3=[data3 data2];
%     data3asym=[data3asym data2asym];
%     
% end
% 
% data3(isnan(data3))=0;
% data3asym(isnan(data3asym))=0;
% temp(:,1)=vecnorm(data3);
% temp(:,2)=vecnorm(data3asym);
% %         aux1=find(temp(:,1)>50);
% %         temp(aux1,:)=nan;
% aux1=adaptData.data.Data;
% adaptData.data=adaptData.data.appendData(temp,{'UnBiasNormEMG','UnBiasNormEMGasym'},...
%     {'Context specifci unbais Norm of all the muscles','Context specifci unbais Norm asym of all the muscles'});  % Adding parameter for to adaptData

%% Plot some of the parameters 

cond={'TM base','Adaptation','Post 1'};
params= {'sTAsNorm','fTAsNorm'};
% adaptData.plotAvgTimeCourse(adaptData,params)
% adaptData.plotAvgTimeCourse(adaptData,params,adaptData.metaData.conditionName,5)
adaptData.plotAvgTimeCourse(adaptData,params,cond,5)
% params= label(15:end);
% % adaptData.plotAvgTimeCourse(adaptData,params)
% % adaptData.plotAvgTimeCourse(adaptData,params,adaptData.metaData.conditionName,5)
% adaptData.plotAvgTimeCourse(adaptData,params,cond,5) 
% ylim([-.5 3])
%% Save params file 

% save([subID 'paramsEMGnorm.mat'],'adaptData','-v7.3')
