%%load 

%  load('/Volumes/Users/Dulce/R01_Nimbus2021/NTS_01/Reprocessed 06-07-2021/NTS_01params.mat') %We use NTS_01 as our base
load('Y:\Dulce\R01_Nimbus2021\NTS_01\Reprocessed 06-07-2021\NTS_01params.mat')
Data = adaptData.getParamInCond('singleStanceSpeedSlow','adaptation'); Data(isnan(Data(:,:)),:) = [];
speedFactor_slow_Ref = 1.17;
speedFactor_slow=speedFactor_slow_Ref* 1.0596;
Slow_OGspeed_late = speedFactor_slow*nanmean(Data(end-46:end-5))/1000

Data = adaptData.getParamInCond('singleStanceSpeedFast','adaptation'); Data(isnan(Data(:,:)),:) = [];
speedFactor_fast_Ref =  1.38;
speedFactor_fast=speedFactor_fast_Ref*1.03*0.91;
Fast_OGspeed_late = speedFactor_fast*nanmean(Data(end-46:end-5))/1000

speedFactor = 1;

deltaspeed = speedFactor*(Fast_OGspeed_late-Slow_OGspeed_late);
midspeed = (speedFactor*(Fast_OGspeed_late+Slow_OGspeed_late))/2;

% cd('/Volumes/Users/Dulce/R01_Nimbus2021/CTR_03/Speed_Profiles')

%% This is for the nimbus subjects 
NTS_01fast=0.785; %Do not change this
NTS_01slow= 0.462; %Do not change this

NimbusFast=1.35 ; %Update this from the "plotSpeedGroups.m" ratio
NimbusSlow=1.30 ; %Update this from the "plotSpeedGroups.m" ratio
Fast_OGspeed_late = NTS_01fast*NimbusFast
Slow_OGspeed_late = NTS_01slow*NimbusSlow
speedFactor = 1;
deltaspeed =speedFactor*(Fast_OGspeed_late-Slow_OGspeed_late);
midspeed = (speedFactor*(Fast_OGspeed_late+Slow_OGspeed_late))/2;


%% Adaptation 
velL = speedFactor*Fast_OGspeed_late*ones(800,1);

velR = [speedFactor*Fast_OGspeed_late*ones(50,1);(speedFactor*Fast_OGspeed_late-(deltaspeed/4))*ones(50,1);...
    (speedFactor*Fast_OGspeed_late-(deltaspeed/2))*ones(50,1);...
    (speedFactor*Fast_OGspeed_late-(3*deltaspeed/4))*ones(50,1);(speedFactor*Fast_OGspeed_late-(deltaspeed))*ones(600,1)];

% save(['Adaptation_800strides_fast_', num2str(speedFactor_fast), '_slow_', num2str(speedFactor_slow),'.mat'],'velL','velR') 
save('Adaptation.mat','velL','velR') 

%% Short Split  

% Positive 
velL = speedFactor*Fast_OGspeed_late*ones(30,1);
velR = speedFactor*Slow_OGspeed_late*ones(30,1);

% save(['Pos_30strides_', num2str(speedFactor_fast), '_slow_', num2str(speedFactor_slow),'.mat'],'velL','velR') 
save(['Pos_30strides.mat'],'velL','velR') 

%%
% Negative
velR = speedFactor*Fast_OGspeed_late*ones(30,1);
velL = speedFactor*Slow_OGspeed_late*ones(30,1);

% save(['Neg_30strides_', num2str(speedFactor_fast), '_slow_', num2str(speedFactor_slow),'.mat'],'velL','velR') 

save(['Neg_30strides.mat'],'velL','velR') 

%% Baselines 
str_num = 150;

%% %Slow
velR = speedFactor*Slow_OGspeed_late*ones(str_num,1);
velL = speedFactor*Slow_OGspeed_late*ones(str_num,1);

% save(['SlowBaseline_150strides_', num2str(speedFactor_fast), '_slow_', num2str(speedFactor_slow),'.mat'],'velL','velR') 
save(['SlowBaseline_150strides.mat'],'velL','velR') 

%% %Fast

velR = speedFactor*Fast_OGspeed_late*ones(str_num,1);
velL = speedFactor*Fast_OGspeed_late*ones(str_num,1);


% save(['FastBaseline_150strides_', num2str(speedFactor_fast), '_slow_', num2str(speedFactor_slow),'.mat'],'velL','velR')
save(['FastBaseline_150strides.mat'],'velL','velR')

%% %Mid 


velR = midspeed*ones(str_num,1);
velL = midspeed*ones(str_num,1);
% save(['MidBaseline_150strides_', num2str(speedFactor_fast), '_slow_', num2str(speedFactor_slow),'.mat'],'velL','velR')
save(['MidBaseline_150strides.mat'],'velL','velR')

%% Shor pertutrbation shoes on 
str_num = 30;

velR = speedFactor*Fast_OGspeed_late*ones(str_num,1);
velL = speedFactor*Fast_OGspeed_late*ones(str_num,1);


% save(['FastBaseline_150strides_', num2str(speedFactor_fast), '_slow_', num2str(speedFactor_slow),'.mat'],'velL','velR')
save(['FastBaseline_30strides.mat'],'velL','velR')
%% Fast baseline 50 strides
str_num = 50;

velR = speedFactor*Fast_OGspeed_late*ones(str_num,1);
velL = speedFactor*Fast_OGspeed_late*ones(str_num,1);


% save(['FastBaseline_150strides_', num2str(speedFactor_fast), '_slow_', num2str(speedFactor_slow),'.mat'],'velL','velR')
save(['FastBaseline_50strides.mat'],'velL','velR')

