clear all
poster_colors;
colorOrder=[p_red; p_orange; p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]];

sqrtFlag=false;
loop=0;
Li=[];

%group=2;
%clear all

labels={'OA_{TR}','OA_{TS}','Stroke_{TR}','YA_{TR}','CTR','CTS','NTR','NTS','YA_{TS}','YA'};
groups=[5 6 7 8];
plotindv=0;

%  figure(1)
for group= groups
    loop=loop+1;
    C=[];
    modelRed=[];
    % OATR =1
    % OATS=2
    % stroke=3
    % YATR=4
    if group==1
        fname= 'dynamicsData_C_s12V2.h5';
        
        subj= [1 3:5 10:12];
%         subj= [1:12];
        load('OA_TR_fixDandC_160322T155119.mat')
        color=[0.9290 0.6940 0.1250];
        
    elseif group==2
        fname= 'dynamicsData_AUF_s7.h5';
        subj= [2 4 6];
        load('OA_TS_fixCandD_Adaptation070422T142847.mat')
        color=[0.4940 0.1840 0.5560];
        
    elseif group==3
        fname='dynamicsData_Stroke.h5';
         subj=[1:13];
         subj=[1:3 5:13];
%         subj=[1:3 5 7 9:13];
        load('Stroke_TR_fixCandD_040422T114934.mat')
%         load('OA_TR_fixDandC_160322T155119.mat')
        color= [0.4660 0.6740 0.1880];
        
    elseif group==4
        fname='dynamicsData_ATR_V4.h5';
        subj=[1:4];
        load('YA_TR_fixDandCV4_20220316T114557.mat')
        color=[0 0.4470 0.7410];
    elseif group==5
        fname='dynamicsData_CTR.h5';
%         subj=[2:4];
        subj=[3:4];
%         subj=[2:4];
        load('C_8_Asym_AdaptationPosShort.mat')
        color=[0.3010 0.7450 0.9330];
    elseif group==6
        fname='dynamicsData_CTS.h5';
        subj=[1 3:5];
        load('C_8_Asym_AdaptationPosShort.mat')
        color=[0.6350 0.0780 0.1840];
    elseif group==7
        fname='dynamicsData_NTR.h5';
        subj=[1:2 4];
        load('N_10_Asym_AdaptationPosShort.mat')
        color=p_fade_green;
    elseif group==8
        fname='dynamicsData_NTS.h5';
        subj=[1:5];
        load('N_10_Asym_AdaptationPosShort.mat')
        color=p_red;
        
    elseif group==9
        fname='dynamicsData_ATS_V6.h5';
        subj=[1:9 11];
                load('YA_TS_fixCandD1_280322T212228.mat')
        color=[0.8500 0.3250 0.0980];
%         color=p_fade_blue;

    elseif group==10
        fname='dynamicsData_ATall.h5';
        subj=[1:6 8:13];
        load('A_15_Asym_EarlyLate40Adaptation.mat')
        color=p_fade_red;
    end
    
    % figure
    X1=[];
    X2=[];
    i=0;
    for s=subj
        
        
%         p = datasample([1:7],4,'Replace',true);
        i=i+1;
        subjIdx=[s];%
        [Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag,fname);
        Uf=[U;ones(size(U))];
        datSet=dset(Uf,Yasym');
        

        binwith=5;
        %% Reduce data
        % Y=datSet.out;
        % U=datSet.in;
        % X=Y-(Y/U)*U; %Projection over input
        % s=var(X'); %Estimate of variance
        % flatIdx=s<.005; %Variables are split roughly in half at this threshold
        
        
        %% Free model - Linear regression - Asymmetry
        if ~isempty(modelRed)
            C=modelRed.C;
        end
        Cinv=pinv(C)';
        X2asym = Yasym*Cinv; %x= y/C
        Y2asym= C * X2asym' ; %yhat = C
        
        

        X1(:,i)=X2asym(:,1);
        

        X2(:,i)=X2asym(:,2);

        if plotindv
            figure(1)
            subplot(2,1,1)
            hold on
            plot( movmean(X2asym(:,1),binwith))
            ylabel('X_{reactive}')
            
            subplot(2,1,2)
            plot(movmean(X2asym(:,2),binwith))
            hold on
            ylabel('X_{learning}')
            
        end
        
        
    end
    %%
    
    figure(10)
    cond={'TMbase','Adaptation','AdaptationEnd','Post1'};
    if group==1 || group==2 || group==3 || group==4 || group==9 || group==10
%         strides=[50 950 1140];
%         ini=[1 51 951];
%         sz=[50 900 190];
  if group==4
        
        strides=[50 900 940 1140];
        ini=[1 51 901 941];
        sz=[50 850 40 200];
    
    else
        strides=[50 900 950 1140];
        ini=[1 51 901 951];
        sz=[50 850 50 190];
  end
    else
        strides=[50 600 800];
        ini=[1 51 601];
        sz=[50 550 200];
        
%         strides=[50 600 800];
%         ini=[1 51 601];
%         sz=[50 550 200];

        strides=[50 550 600 800];
        ini=[1 51  551 601];
        sz=[50 500 50 200];

        
    end
    Opacity=0.5;
    %
    scale=[];
    scale2=[];
    % figure
    
    for x=1:size(X2asym,2)
        if x==1
            X=X1;
            timecourse=1:5;
            steeadystate=6;
            AE=7;
            delta=8;
        else
            X=X2;
            timecourse=9:13;
            steeadystate=14;
            AE=15;
            delta=16;
            
        end
    Xstart=1;
    for c=1:length(cond)
        temp=[];
        
        
        subplot(2,8,timecourse)
        hold on
        temp=nan(strides(c),size(X1,2));
            
        temp(1:sz(c),:)=movmean(X(ini(c):strides(c),:),5,'omitnan'); %moving average of 5

        y=nanmean(temp,2)'; %across subjects mean
        if c==1
        
        bias=0;%nanmean(y);
        end
        
        if max(abs(y))>1  %To scale the hidden state to be max 1
            
            scale=(1/max(abs(y)));
            
        end
        
        if isempty(scale)
            scale=1;
        end
        
        
        condLength=length(y);
        if c==4
            if group==1 || group==2 || group==3 || group==4 || group==9 || group==10
            x=1010:1010+condLength-1;
            else
               x=680:680+condLength-1; 
            end
        else
        x=Xstart:Xstart+condLength-1;
        end
        E=std(temp,0,2,'omitnan')./sqrt(size(temp,2)); %Standar error
        [Pa, Li{loop}]= nanJackKnife(x,(y-bias)*scale,E',color,color+0.5.*abs(color-1),Opacity);
        yline(0)
        
        
        if c==3
            subplot(2,8,steeadystate)
            ss_data=nanmean(y(1:10));
            bar(loop,ss_data*scale,'FaceColor',color,'BarWidth',0.9)
            hold on
            errorbar(loop,nanmean(y(1:10))*scale,E(1),'LineStyle','none','color','k','LineWidth',2)
            for ss=1:size(X1,2)
                plot(loop-0.03,nanmean(temp(1:10,ss))*scale,'.','MarkerSize', 15, 'Color',[150 150 150]./255)
            end
            
            
        end
        
        if c==4
            subplot(2,8,AE)
            bar(loop,y(1)*scale,'FaceColor',color,'BarWidth',0.9)
            hold on
            errorbar(loop,y(1)*scale,E(1),'LineStyle','none','color','k','LineWidth',2)
            for ss=1:size(X1,2)
                plot(loop-0.03,temp(1,ss)*scale,'.','MarkerSize', 15, 'Color',[150 150 150]./255)
            end
            
            subplot(2,8,delta)
            bar(loop,(ss_data-y(1))*scale,'FaceColor',color,'BarWidth',0.9)
            hold on
            errorbar(loop,y(1)*scale,E(1),'LineStyle','none','color','k','LineWidth',2)
            for ss=1:size(X1,2)
                plot(loop-0.03,nanmean(temp(1:10,ss))*scale,'.','MarkerSize', 15, 'Color',[150 150 150]./255)
            end
 
        end
        
        


        
% 
%         subplot(2,8,9:13)
%         hold on
%         temp=nan(strides(c),size(X2,2)); %moving average of 5
%         temp(1:sz(c),:)=movmean(X2(ini(c):strides(c),:),5,'omitnan'); %across subjects mean
%         y=nanmean(temp,2)';
%         if c==1
%             bias2=0;%nanmean(y);
%         end
%         
%         if max(abs(y))>1  %To scale the hidden state to be max 1
%             
%             scale2=(1/max(abs(y)));
%             
%             if group==1
%                 oldscale=1;%scale2;
%             end
%             
%             if group==3
%                 scale2=oldscale;
%             end
%                 
%             
%         end
%         
%         if isempty(scale2)
%             scale2=1;
%         end
%         
% %         if c==4
% %             scale2=1;
% %         end
%         
%         condLength=length(y);
%         
% %         x=Xstart:Xstart+condLength-1;
%         E=std(temp,0,2,'omitnan')./sqrt(size(temp,2)); %Standar error
% %         E(isnan(E))=[];
%         [Pa, Li{loop}]= nanJackKnife(x,(y-bias2)*scale2,E',color,color+0.5.*abs(color-1),Opacity);
%         yline(0)
%         
%         if c==3
%             subplot(2,8,14)
%             ss_data=nanmean(y(1:10));
%             bar(loop,ss_data*scale2,'FaceColor',color,'BarWidth',0.9)
%             hold on
%             errorbar(loop,nanmean(y(1:10))*scale2,E(1),'LineStyle','none','color','k','LineWidth',2)
%             for ss=1:size(X1,2)
%                 plot(loop-0.03,nanmean(temp(1:10,ss))*scale2,'.','MarkerSize', 15, 'Color',[150 150 150]./255)
%             end
%         end
%         
%         if c==4
%             subplot(2,8,15)
%             bar(loop,y(1)*scale2,'FaceColor',color,'BarWidth',.9)
%             hold on
%             errorbar(loop,y(1)*scale2,E(1),'LineStyle','none','color','k','LineWidth',2)
%             
%             for ss=1:size(X1,2)
%                 plot(loop-0.03,temp(1,ss)*scale2,'.','MarkerSize', 15, 'Color',[150 150 150]./255)
%             end
%             
%             
%             subplot(2,8,16)
%             bar(loop,(ss_data-y(1))*scale2,'FaceColor',color,'BarWidth',.9)
%             hold on
%             errorbar(loop,y(1)*scale2,E(1),'LineStyle','none','color','k','LineWidth',2)
%             
%             for ss=1:size(X1,2)
%                 plot(loop-0.03,temp(1,ss)*scale2,'.','MarkerSize', 15, 'Color',[150 150 150]./255)
%             end
%         end
%         
        

        
        Xstart=Xstart+condLength;
        
        hold on
        
        
    end

    %%
    
    subplot(2,8,timecourse)
    if group==1 || group==2 || group==3 || group==4 || group==9 || group==10
      if length(cond)==4
            pp=patch([50 1000 1000 50],[-1.2 -1.2 1.2 1.2],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
            uistack(pp,'bottom')
        else
            
            pp=patch([50 950 950 50],[-1.2 -1.2 1.2 1.2],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
            uistack(pp,'bottom') 
        end
        ylabel('X_{reactive}')
        axis tight
    else
        if length(cond)==4
            pp=patch([50 650 650 50],[-1.2 -1.2 1.2 1.2],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
            uistack(pp,'bottom')
        else
            pp=patch([50 600 600 50],[-1.2 -1.2 1.2 1.2],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
            uistack(pp,'bottom')
        end
        
        ylabel('X_{reactive}')
        axis tight
        
    end
    
    
%     subplot(2,8,9:13)
%     if group==1 || group==2 || group==3 || group==4 || group==9 || group==10
%         
%         if length(cond)==4
%             pp=patch([50 1000 1000 50],[-1.2 -1.2 1.2 1.2],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
%             uistack(pp,'bottom')
%         else
%             
%             pp=patch([50 950 950 50],[-1.2 -1.2 1.2 1.2],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
%             uistack(pp,'bottom') 
%         end
%         
%         ylabel('X_{reactive}')
%         axis tight
%     else
%         if length(cond)==4
%             pp=patch([50 650 650 50],[-1.2 -1.2 1.2 1.2],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
%             uistack(pp,'bottom')
%         else
%             pp=patch([50 600 600 50],[-1.2 -1.2 1.2 1.2],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
%             uistack(pp,'bottom')
%         end
%         
%         ylabel('X_{reactive}')
%         axis tight
%         
%     end
    
subplot(2,8,steeadystate)
set(gca, 'XTick', 1:length(groups), 'XTickLabels', labels(groups))
title('Steady State')
subplot(2,8,AE)
title('Early Post')
set(gca, 'XTick', 1:length(groups), 'XTickLabels', labels(groups))
subplot(2,8,delta)
title('Delta')
set(gca, 'XTick', 1:length(groups), 'XTickLabels', labels(groups))
%     subplot(2,7,13)
%     set(gca, 'XTick', 1:length(groups), 'XTickLabels', labels(groups))
%     
    end 
end
set(gcf,'color','w')
legend([Li{:}]',[labels(groups)])