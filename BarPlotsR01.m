% Script to plot the bar plots for the R01

load('Data_R01_stats.mat')
fz=14;
groups={'CTR','CTS','NTR','NTS','OATR','OATS','NOATR','NOATS','STR','STS','NSTR','NSTS'};
mkrsize=10;
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

colors=[0 0.4470 0.7410;0.8500 0.3250 0.0980;0.4940 0.1840 0.5560;0.9290 0.6940 0.1250;0.4660 0.6740 0.1880;0.3010 0.7450 0.9330];
gToplot=[5:12];
gToplotStep=gToplot(1):2:gToplot(end);
%% Getting var

data{1}.epost_sd=nan(1,7);
data{2}.epost_sd=nan(1,7);
data{1}.epost_n=nan(1,7);
data{2}.epost_n=nan(1,7);
for l=1:2
    for g=1:7
        data2=data{l}.epost_ind(:,g);
        data2= data2(~isnan(data2));
        data{l}.epost_sd(1,g)= std(data2);
        data{l}.epost_n(1,g)=length(data2);
        
        
    end
end


%% X_reactive data{1}
reactive=1;

alpha_control= data{reactive}.epost_mean(CTS)/ data{reactive}.epost_mean(CTR);
alpha_training= data{reactive}.epost_mean(NTR)/data{reactive}.epost_mean(CTR);
delta_context= data{reactive}.epost_mean(NTS)/ data{reactive}.epost_mean(CTR);


%Stroke 
STS=alpha_control*data{reactive}.epost_mean(STR);
NSTR=alpha_training* data{reactive}.epost_mean(STR);
NSTS=delta_context*data{reactive}.epost_mean(STR);

%Older Adults 
NOATR=alpha_training* data{reactive}.epost_mean(OATR);
NOATS=delta_context*data{reactive}.epost_mean(OATR);

data_reactive=nan(12,1);
data_reactive_se=nan(12,1);
data_reactive_sd=nan(12,1);
data_reactive_n=nan(12,1);
data_reactive_indv=nan(10,12);

data_reactive(1:6)=data{reactive}.epost_mean(1:6);
data_reactive(7)=NOATR;
data_reactive(8)=NOATS;
data_reactive(9)=data{reactive}.epost_mean(7);
data_reactive(10)=STS;
data_reactive(11)=NSTR;
data_reactive(12)=NSTS;


data_reactive_se(1:6)=data{reactive}.epost_se(1:6);
data_reactive_se(9)=data{reactive}.epost_se(7);


data_reactive_sd(1:6)=data{reactive}.epost_sd(1:6);
data_reactive_sd(9)=data{reactive}.epost_sd(7);

data_reactive_sd(1:6)=data{reactive}.epost_sd(1:6);
data_reactive_sd(9)=data{reactive}.epost_sd(7);

data_reactive_n(1:6)=data{reactive}.epost_n(1:6);
data_reactive_n(9)=data{reactive}.epost_n(7);

data_reactive_indv(:,1:6)=data{reactive}.epost_ind(:,1:6);
data_reactive_indv(:,9)=data{reactive}.epost_ind(:,7);


figure 
subplot(2,2,1)
hold on
loop=(gToplot(2)/2)-1;
colum=0;
xx=0;
for g=gToplot
    xx=xx+1;
    if rem(g, 2) == 1
        loop=loop+1;
%     bar(g, data_reactive(g),'FaceColor',colors(loop,:))
    plot(xx, data_reactive(g),'s','MarkerFaceColor',colors(loop,:),'MarkerSize',mkrsize,'MarkerEdgeColor','k')
    errorbar(xx,data_reactive(g),data_reactive_se(g),'LineStyle','none','color','k','LineWidth',2)
    
    if g==1 || g==3 || g==5 || g==9
%         colum=colum+1;
        for ss=1:data_reactive_n(g)
            
            plot(xx+0.1,data_reactive_indv(ss,g),'.','MarkerSize', 15, 'Color',[150 150 150]./255)
        end
    end
    
    else
%         bar(g, data_reactive(g),'FaceColor','w','EdgeColor',colors(loop,:),'LineWidth',1.5)
        plot(xx, data_reactive(g),'s','MarkerFaceColor','w','MarkerEdgeColor',colors(loop,:),'LineWidth',1.5,'MarkerSize',mkrsize)
        errorbar(xx,data_reactive(g),data_reactive_se(g),'LineStyle','none','color','k','LineWidth',2)
        
        if g==2 || g==4 || g==6
%              colum=colum+1;
             for ss=1:data_reactive_n(g)
                 
                 plot(xx+0.1,data{reactive}.epost_ind(ss,g),'.','MarkerSize', 15, 'Color',[150 150 150]./255)
             end
        end
    end
        
    
    
end
ylabel('X_{reactive} ','FontSize', fz);
set(gca, 'XTick', 1:length(gToplot), 'XTickLabels',  groups( gToplot))
xlim([0 length(gToplot)+1])
% Generalization index 
subplot(2,2,3)
hold on
g=0;
aux=1;
for paris=gToplotStep
    g=g+1; 
    deltas(g)=data_reactive(paris+1)-data_reactive(paris);
    combine_var(g)=(1/data_reactive_n(paris+1))*(data_reactive_sd(paris+1))^2 +data_reactive(paris)*(data_reactive_sd(paris))^2;
    
    if g==4
    combine_var(g)=(combine_var(2)/combine_var(1))*combine_var(3);
    
    end
    
    if rem(g, 2) == 0
        aux=aux+1;
        
         plot(g,deltas(g-1),"o","MarkerSize",25, 'MarkerFaceColor',colors(g-1,:), 'MarkerEdgeColor','k');
          errorbar(g,deltas(g-1),sqrt(combine_var(g-1)),'LineStyle','none','color','k','LineWidth',2)
         plot(g,deltas(g),"o","MarkerSize",25, 'MarkerEdgeColor',colors(g,:), 'MarkerFaceColor','w');
         errorbar(g,deltas(g),sqrt(combine_var(g)),'LineStyle','none','color','k','LineWidth',2)
        
        
    end
    
end
yline(0)
xlim([0 7])
% axis([1 7 -2 .2])
labels={'Young','Older','Stroke'};
set(gca, 'XTick', [2:2:6], 'XTickLabels',  labels)
% set(gca, 'XTick', 1:length(gToplotStep), 'XTickLabels',  labels)

%% X_learning data{2}
% We are preseving the proportion form the CTS/CTS and that the NTS and NTR
% are not different 

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

data_learning=nan(12,1);
data_learning_se=nan(12,1);
data_learning_sd=nan(12,1);
data_learning_n=nan(12,1);
data_learning_indv=nan(10,12);

data_learning(1:6)=data{learning}.epost_mean(1:6);
data_learning(7)=NOATR;
data_learning(8)=NOATS;
data_learning(9)=data{learning}.epost_mean(7);
data_learning(10)=STS;
data_learning(11)=NSTR;
data_learning(12)=NSTS;

data_learning_se=nan(12,1);
data_learning_se(1:6)=data{learning}.epost_se(1:6);
data_learning_se(9)=data{learning}.epost_se(7);

data_learning_sd(1:6)=data{learning}.epost_sd(1:6);
data_learning_sd(9)=data{learning}.epost_sd(7);

data_learning_n(1:6)=data{learning}.epost_sd(1:6);
data_learning_n(9)=data{learning}.epost_sd(7);

data_learning_indv(:,1:6)=data{learning}.epost_ind(:,1:6);
data_learning_indv(:,9)=data{learning}.epost_ind(:,7);
% figure 
subplot(2,2,2)
hold on
loop=(gToplot(2)/2)-1;
colum=0;
xx=0;
for g=gToplot
    xx=xx+1;
    if rem(g, 2) == 1
        loop=loop+1;
%     bar(g, data_learning(g),'FaceColor',colors(loop,:))
    plot(xx, data_learning(g),'s','MarkerFaceColor',colors(loop,:),'MarkerSize',mkrsize,'MarkerEdgeColor','k')
    errorbar(xx,data_learning(g),data_learning_se(g),'LineStyle','none','color','k','LineWidth',2)
    
    if g==1 || g==3 || g==5 || g==9
%         colum=colum+1;
        for ss=1:data_reactive_n(g)
            
            plot(xx+0.1,data_learning_indv(ss,g),'.','MarkerSize', 15, 'Color',[150 150 150]./255)
        end
    end
    else
%         bar(g, data_learning(g),'FaceColor','w','EdgeColor',colors(loop,:),'LineWidth',1.5)
        plot(xx, data_learning(g),'s','MarkerFaceColor','w','MarkerEdgeColor',colors(loop,:),'LineWidth',1.5,'MarkerSize',mkrsize)
        errorbar(xx,data_learning(g),data_learning_se(g),'LineStyle','none','color','k','LineWidth',2)
        
        if g==2 || g==4 || g==6
            colum=colum+1;
            for ss=1:data_reactive_n(g)
                
                plot(xx+0.1,data{learning}.epost_ind(ss,g),'.','MarkerSize', 15, 'Color',[150 150 150]./255)
            end
        end
    end
        
    
    
end
ylabel('X_{contextual}', 'FontSize', fz);
xlim([0 length(gToplot)+1])
set(gca, 'XTick', 1:length(gToplot), 'XTickLabels',  groups( gToplot))
set(gcf,'color','w');

% Generalization index 
subplot(2,2,4)
hold on
g=0;
aux=1;
for paris=gToplotStep
    g=g+1; 
    deltas_learning(g)=data_learning(paris+1)-data_learning(paris);
    combine_var_learning(g)=(1/data_learning_n(paris+1))*(data_learning_sd(paris+1))^2 +data_learning(paris)*(data_learning_sd(paris))^2;
    
    if g==4
        combine_var_learning(g)=(combine_var_learning(2)/combine_var_learning(1))*combine_var_learning(3);
        
    end
    if rem(g, 2) == 0
        aux=aux+1;
        
         plot(g,deltas_learning(g-1),"o","MarkerSize",25, 'MarkerFaceColor',colors(g-1,:), 'MarkerEdgeColor','k');
          errorbar(g,deltas_learning(g-1),sqrt(combine_var_learning(g-1)),'LineStyle','none','color','k','LineWidth',2)
         plot(g,deltas_learning(g),"o","MarkerSize",25, 'MarkerEdgeColor',colors(g,:), 'MarkerFaceColor','w');
          errorbar(g,deltas_learning(g),sqrt(combine_var_learning(g)),'LineStyle','none','color','k','LineWidth',2)
        
        
    end
    
end
% axis([1 7 -2 1.5])
xlim([0 7])
set(gca, 'XTick', [2:2:6], 'XTickLabels',  labels)
% set(gca, 'XTick', 1:length(gToplotStep), 'XTickLabels',  labels)
yline(0)
