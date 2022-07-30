% Script to plot the bar plots for the R01

load('Data_R01_stats.mat')

%% Proportions 

%Everthing is going to be estimating the the proportion between the CTR and
%the unknow groups (NOATR, NOATS, STS, SNTS, SNTS)
 
CTR=1;
CTS=2;
NTR=3;
NTS=4;
OATR=5;
OATS=6;
STR=7;




%% X_reactive data{1}
reactive=1;

alpha= data{1}.epost_mean(CTS)/ data{1}.epost_mean(CTR);



%% X_learning data{2}
learning=2;

alpha_control= data{learning}.epost_mean(CTS)/ data{learning}.epost_mean(CTR);
alpha_context= data{learning}.epost_mean(NTR)/ data{learning}.epost_mean(CTR);

% Stroke 
STS=data{learning}.epost_mean(STR)*alpha_control;
NSTS=data{learning}.epost_mean(STR)*alpha_context;
NSTR=NSTS; 

%Older Adults
NOATS=data{learning}.epost_mean(OATR)*alpha_context;
NOATR=NOATS; 

% Organize data for plot

data_plot=nan(12,1);

data_plot(1:6)=data{learning}.epost_mean(1:6);
data_plot(7)=NOATR;
data_plot(8)=NOATS;
data_plot(9)=data{learning}.epost_mean(7);
data_plot(7)=NOATR;
data_plot(8)=NOATS;





