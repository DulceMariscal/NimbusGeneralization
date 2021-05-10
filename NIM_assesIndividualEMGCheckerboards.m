% clear; close all;

% load('/Users/samirsherlekar/Desktop/emg/Data/normalizedYoungEmgData.mat');
% load('C:\Users\dum5\Box\GeneralizationStudy Data\NormalizedFastYoungEMGData.mat')
% sub={'YL02params'};
subID = 'NimbG_BoyanAllMuscles';
sub={[subID 'params']};

normalizedTMFullAbrupt=adaptationData.createGroupAdaptData(sub);

ss =normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');

% ss =TMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm'); %Dulce 
s2 = regexprep(ss,'^Norm','dsjrs');
normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ss,s2);
% normalizedTMFullAbrupt=studyData.TMFullAbrupt.renameParams(ss,s2);

% muscleOrder={'TA','MG','SEMT','VL','RF'};
muscleOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'HIP'};
% muscleOrder={'TA', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'HIP'};

n_muscles = length(muscleOrder);
useLateAdaptAsBaseline=false;

n_subjects = 1;
extremaMatrixYoung = NaN(n_subjects,n_muscles * 2,2);


ep=defineEpocNimbusShoes('nanmean');
refEp = defineReferenceEpoch('OGNimbus',ep);
refEpLate = defineReferenceEpoch('Adaptation',ep);
% refEp = defineEpochYoungLongAdaptation('Fast',ep);

newLabelPrefix = defineMuscleList(muscleOrder);

% normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,ep(1,:));
normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,refEp);


ll=normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');
%ll = normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^(s|f)[A-Z]+_s');

l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ll,l2);

newLabelPrefix = regexprep(newLabelPrefix,'_s','s');

for i = 1:n_subjects
    

    adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i}; 

    fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
    ph=tight_subplot(1,length(ep)+1,[.03 .005],.04,.04);
    flip=true;

    adaptDataSubject.plotCheckerboards(newLabelPrefix,refEp,fh,ph(1,1),[],flip); %First, plot reference epoch:   
    [~,~,labels,dataE{1},dataRef{1}]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep,fh,ph(1,2:end),refEp,flip);%Second, the rest:
    adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(7,:),fh,ph(1,8),refEpLate,flip);%Second, the rest:
    
    
    set(ph(:,1),'CLim',[-1 1]);
%     set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*2);
    set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1.5);
    set(ph,'FontSize',8)
    pos=get(ph(1,end),'Position');
    axes(ph(1,end))
    colorbar
    set(ph(1,end),'Position',pos);
    
   
    
    extremaMatrixYoung(i,:,1) =  min(dataRef{1});
    extremaMatrixYoung(i,:,2) =  max(dataRef{1});
    
end
set(gcf,'color','w');



%% Regressor V2 - Update from disucssion on Tuesday MAy 4, 2021 

% Adapt VR- baseline VR
% OG base - baseline VR 
% baseline - EMG_split(-) 

sub={'NimbG_BoyanAllMusclesparams'};

normalizedTMFullAbrupt=adaptationData.createGroupAdaptData(sub);

ss =normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');

% ss =TMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm'); %Dulce 
s2 = regexprep(ss,'^Norm','dsjrs');
normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ss,s2);
% normalizedTMFullAbrupt=studyData.TMFullAbrupt.renameParams(ss,s2);

% muscleOrder={'TA','MG','SEMT','VL','RF'};
muscleOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'HIP'};
% muscleOrder={'TA', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'HIP'};

n_muscles = length(muscleOrder);
useLateAdaptAsBaseline=false;

n_subjects = 1;
extremaMatrixYoung = NaN(n_subjects,n_muscles * 2,2);



ep=defineEpocNIM_OG_UpdateV1('nanmean');
refEpAdaptLate = defineReferenceEpoch('Adaptation',ep);
refEpOGBase=defineReferenceEpoch('OGbase',ep);
refEpOGpost= defineReferenceEpoch('OGpost_{Late}',ep);
refEp= defineReferenceEpoch('TMbase',ep);

newLabelPrefix = defineMuscleList(muscleOrder);

% normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,ep(1,:));
normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,refEp);


ll=normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');
%ll = normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^(s|f)[A-Z]+_s');

l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ll,l2);

newLabelPrefix = regexprep(newLabelPrefix,'_s','s');


for i = 1:n_subjects
    

    adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i}; 

    fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
    ph=tight_subplot(1,5,[.03 .005],.04,.04);
    flip=true;
    
    Data = {}; %in order: adapt, dataEnvSwitch, dataTaskSwitch, dataTrans1, dataTrans2
    %all labels should be the same, no need to save again.
    [~,~,labels,Data{1},dataRef2]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(3,:),fh,ph(1,1),refEp,flip); %  EMG_split(-) - TM base with Nimbus, adaptation
    [~,~,~,Data{2},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(5,:),fh,ph(1,2),refEpOGBase,flip); %  base - OG base, env switching
    [~,~,~,Data{3},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(6,:),fh,ph(1,3),refEpAdaptLate,flip); % baseline Nimbus - Adapt SS, task switching (within env)
    [~,~,~,Data{4},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(8,:),fh,ph(1,4),refEpAdaptLate,flip); %OGafter - Adaptation_{SS} , transition 1
    [~,~,~,Data{5},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(11,:),fh,ph(1,5),refEpOGpost,flip); %Nimbus post early - OG post late, transition 2
%     [~,~,labels,dataE{1},dataRef{1}]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep,fh,ph(1,2:end),refEp,flip);%Second, the rest:    
    

    set(ph(:,1),'CLim',[-1 1]);
%     set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*2);
    set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1.5);
    set(ph,'FontSize',8)
    pos=get(ph(1,end),'Position');
    axes(ph(1,end))
    colorbar
    set(ph(1,end),'Position',pos);
    
   
    
    extremaMatrixYoung(i,:,1) =  min(dataRef2);
    extremaMatrixYoung(i,:,2) =  max(dataRef2);
    
end
set(gcf,'color','w');

%% Run regression analysis V2 - single subject
%handling nan value?
%normalize data? 
clc;
for i = 1:size(Data,2)
    Data{i} = reshape(Data{i}, [],1); %make it a column vector
end
tableData=table(Data{1},Data{2},Data{3},Data{4},Data{5},'VariableNames',{'Adapt', 'EnvSwitch', 'TaskSwitch', 'Trans1', 'Trans2'});

fitTrans1NoConst=fitlm(tableData,'Trans1 ~ TaskSwitch+EnvSwitch+Adapt-1')%exclude constant
Rsquared = fitTrans1NoConst.Rsquared
fitTrans1=fitlm(tableData,'Trans1 ~ TaskSwitch+EnvSwitch+Adapt')%exclude constant

fitTrans2NoConst=fitlm(tableData,'Trans2 ~ TaskSwitch+EnvSwitch+Adapt-1')%exclude constant
Rsquared = fitTrans2NoConst.Rsquared
fitTrans2=fitlm(tableData,'Trans2 ~ TaskSwitch+EnvSwitch+Adapt')%exclude constant

resDir = 'RegModelResults/';
if ~exist(resDir)
    mkdir(resDir)
end

save([resDir subID 'models'], 'fitTrans1NoConst','fitTrans1','fitTrans2NoConst','fitTrans2')

%% Regressors 

% % baseline - EMG_split(+) 
% % baseline - EMG_split(-)
% % Adapt - baseline
% % OGpost - ADapt SS
% 
% sub={'NimbG_BoyanAllMusclesparams'};
% 
% normalizedTMFullAbrupt=adaptationData.createGroupAdaptData(sub);
% 
% ss =normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');
% 
% % ss =TMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm'); %Dulce 
% s2 = regexprep(ss,'^Norm','dsjrs');
% normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ss,s2);
% % normalizedTMFullAbrupt=studyData.TMFullAbrupt.renameParams(ss,s2);
% 
% % muscleOrder={'TA','MG','SEMT','VL','RF'};
% muscleOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'HIP'};
% % muscleOrder={'TA', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'HIP'};
% 
% n_muscles = length(muscleOrder);
% useLateAdaptAsBaseline=false;
% 
% n_subjects = 1;
% extremaMatrixYoung = NaN(n_subjects,n_muscles * 2,2);
% 
% ep=defineEpocNimbusShoesRegressor('nanmean');
% % refEp = defineReferenceEpoch('OGNimbus',ep);
% refEpAdaptLate = defineReferenceEpoch('Adaptation',ep);
% refEpShortPos=defineReferenceEpoch('SplitPos',ep);
% % refEpShortNeg=defineReferenceEpoch('SplitNeg',ep);
% refEpTM = defineReferenceEpoch('TMBaseShoes',ep);
% % refEp = defineEpochYoungLongAdaptation('Fast',ep);
% 
% newLabelPrefix = defineMuscleList(muscleOrder);
% 
% % normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,ep(1,:));
% normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,refEp);
% 
% 
% ll=normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');
% %ll = normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^(s|f)[A-Z]+_s');
% 
% l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
% normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ll,l2);
% 
% newLabelPrefix = regexprep(newLabelPrefix,'_s','s');
% 
% 
% for i = 1:n_subjects
%     
% 
%     adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i}; 
% 
%     fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
%     ph=tight_subplot(1,4,[.03 .005],.04,.04);
%     flip=true;
% 
%     adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(6,:),fh,ph(1,3),refEpLate,flip); %OG base - Adapt SS 
%     adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(2,:),fh,ph(1,2),refEpShortPos,flip); % baseline TM - EMG_split(+) 
%     adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(4,:),fh,ph(1,1),refEpTM,flip); %  EMG_split(+) - baseline TM
%     adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(8,:),fh,ph(1,4),refEpLate,flip); %OGafter = Adaptation_{SS} 
% %     [~,~,labels,dataE{1},dataRef{1}]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep,fh,ph(1,2:end),refEp,flip);%Second, the rest:
% %    
%     
%     
%     set(ph(:,1),'CLim',[-1 1]);
% %     set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*2);
%     set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1.5);
%     set(ph,'FontSize',8)
%     pos=get(ph(1,end),'Position');
%     axes(ph(1,end))
%     colorbar
%     set(ph(1,end),'Position',pos);
%     
%    
%     
%     extremaMatrixYoung(i,:,1) =  min(dataRef{1});
%     extremaMatrixYoung(i,:,2) =  max(dataRef{1});
%     
% end
% set(gcf,'color','w');