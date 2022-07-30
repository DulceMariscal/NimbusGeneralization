clear all
poster_colors;
colorOrder=[p_red; p_orange; p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]];
close all

sqrtFlag=false;
loop=0;
Li=[];
binwith=5;
postData=[];
%group=2;
%clear all

labels={'OA_{TR}','OA_{TS}','Stroke_{TR}','YA_{TR}','CTR','CTS','NTR','NTS','YA_{TS}','YA'};
groups=[5 6 7 8 1 2 3];
plotindv=0;
data{1}.epost_ind=nan(10,length(groups));
data{2}.epost_ind=nan(10,length(groups));
data{1}.epost_mean=nan(10,1);
data{2}.epost_mean=nan(10,1);
data{1}.epost_se=nan(10,1);
data{2}.epost_se=nan(10,1);
dots=0;
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
        
        %         subj= [1 3:5 10:12]; %7
        %                 subj= [1:12];
        %                 subj=[1:5 7:8 10:12];  %hand pick to remove lowest SS
        %                 subj=[1:5 7:8 11:12];  %hand pick to remove lowest SS
        subj=[1:5 7:8 11:11];  %Removing outliers 5/26/2022
        load('OA_TR_fixDandC_160322T155119.mat')
        %         load C_12_AsymC4_EarlyLateAdaptation
        color=[0.9290 0.6940 0.1250];
        
    elseif group==2
        fname= 'dynamicsData_AUF_s7.h5';
        subj= [2 4 6];
        %         subj= [1:6];
        load('OA_TS_fixCandD_Adaptation070422T142847.mat')
        %         load AUF_7_AsymC4_EarlyLateAdaptation
        color=[0.4940 0.1840 0.5560];
        
    elseif group==3
        fname='dynamicsData_Stroke.h5';
        %         subj=[1:13];
        %         subj=[1:3 5:13];
        %                 subj=[1:3 5 7 9:13]; %10 hand pick
        subj=[1:3 5 7 9:10 12:13]; %10 hand pick
        subj=[1:3 5 7 9:10 12]; %Removing outliers 5/26/2022
        load('Stroke_TR_fixCandD_040422T114934.mat')
        %             load P_12_AsymC4_EarlyLateAdaptation
        %         load('OA_TR_fixDandC_160322T155119.mat')
        color= [0.4660 0.6740 0.1880];
        
    elseif group==4
        fname='dynamicsData_ATR_V4.h5';
        subj=[1:4];
        load('YA_TR_fixDandCV4_20220316T114557.mat')
        color=[0 0.4470 0.7410];
    elseif group==5
        fname='dynamicsData_CTR.h5';
        %                 subj=[1:4];
        subj=[3:4];
        %                 subj=[2:4];
        load('C_8_Asym_AdaptationPosShort.mat')
        color=[0.3010 0.7450 0.9330];
    elseif group==6
        fname='dynamicsData_CTS.h5';
        subj=[1 3:5];
        load('C_8_Asym_AdaptationPosShort.mat')
        color=[0.6350 0.0780 0.1840];
    elseif group==7
        fname='dynamicsData_NTR.h5';
        %         subj=[1:2 4];
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
        %         subj=[1:6 8:13];
        subj=[1 4:6 8:13]; %hand pick to remove highest SS
        subj=[1 4:6 8:9 11:13]; %9 hand pick to remove highest SS
        subj=[1 5:6 8:13]; %9 hand pick to remove highest SS
        load('A_15_Asym_EarlyLate40Adaptation.mat')
        %         load A_15_AsymC4_EarlyLateAdaptation
        %         color=p_fade_red;
        color=[0 0.4470 0.7410];
    end
    
    % figure
    X1=[];
    X2=[];
    i=0;
    for s=subj
        
        
        i=i+1;
        subjIdx=[s]; %Individual analysis
        [Y,Yasym]=groupDataToMatrixForm(subjIdx,sqrtFlag,fname);
        
        
        
        
        %% Free model - Linear regression - Asymmetry
        if ~isempty(modelRed)
            C=modelRed.C;
        end
        %         C=C(:,1:2);
        Cinv=pinv(C)';
        X2asym = Yasym*Cinv; %x= y/C
        Y2asym= C * X2asym' ; %yhat = C
        
        
        
        X1(:,i)=X2asym(:,1);
        
        
        X2(:,i)=X2asym(:,2);
        
        if plotindv
            figure(3)
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
    
    
    cond={'TMbase','Adaptation','AdaptationEnd','Post1'};
    if group==1 || group==2 || group==3 || group==4 || group==9 || group==10
        
        %Plotting entire adaptation
        %         strides=[50 950 1140];
        %         ini=[1 51 951];
        %         sz=[50 900 190];
        
        if group==4
            %plotting the last 40 strides of adaptation
            strides=[50 900 940 1140];
            ini=[1 51 901 941];
            sz=[50 850 40 200];
            
        else
            %plotting the last 40 strides of adaptation
            strides=[50 900 950 1140];
            ini=[1 51 901 951];
            sz=[50 850 50 190];
        end
    else
        
        %Plotting entire adaptation
        %         strides=[50 600 800];
        %         ini=[1 51 601];
        %         sz=[50 550 200]
        
        
        %plotting the last 40 strides of adaptation
        strides=[50 550 600 800];
        ini=[1 51  551 601];
        sz=[50 500 50 200];
        
        
    end
    Opacity=0.2;
    %
    scale=[];
    scale2=[];
    scaleSS=[];
    % figure
    timecourse=1:2;
    steeadystate=3;
    AE=6;
    timecourseE1=4;
    timecourseE2=5;
    
    for xhat=1:size(X2asym,2)
        
        if xhat==1
            X=X1;
            %             figure(1)
            
            %             timecourse=1:5;
            %             steeadystate=6;
            %             AE=7;
            %             delta=8;
        else
            X=X2;
            %             figure(2)
            %             timecourse=1:5;
            %             steeadystate=6;
            %             AE=7;
            %             delta=8;
            %             timecourse=9:13;
            %             steeadystate=14;
            %             AE=15;
            %             delta=16;
            
        end
        Xstart=1;
        for c=1:length(cond)
            temp=[];
            
            
            %             subplot(2,3,timecourse)
            hold on
            temp=nan(strides(c),size(X1,2));
            if  c==3
                if group==4
                    temp(1:sz(c),:)=movmean(X(strides(c)-39:strides(c),:),5,'omitnan'); %moving average of 5
                else
                    temp(1:sz(c),:)=movmean(X(strides(c)-49:strides(c),:),5,'omitnan'); %moving average of 5
                end
            else
                
                temp(1:sz(c),:)=movmean(X(ini(c):strides(c),:),5,'omitnan'); %moving average of 5
            end
            y=nanmean(temp,2)'; %across subjects mean
            
            
            if c==1
                
                bias=0;%nanmean(y);
                y=[y nan(1,10)];
            end
            
            
            if max(abs(y))>1  %To scale the hidden state to be max 1
                if group==1 || group==3 || group==10
                    scale=1/1.84;%
                else
                    scale=(1/max(abs(y)));%1/1.84;%
                end
                
                
                scaleold=scale;
                
                
                %                 if group==3 || group==10
                %                     scale=scaleold;
                %                 end
                
                
                
                
            end
            
            if isempty(scale)
                scale=1;
            end
            
            
            condLength=length(y);
            if c==4
                scale=1;
                if group==1 || group==2 || group==3 || group==4 || group==9 || group==10
                    x=1010:1010+condLength-1;
                else
                    x=680:680+condLength-1;
                    if ~isempty(scaleSS)
                        scale=scaleSS;
                    end
                end
                
                postData{xhat,loop}=temp;
            else
                x=Xstart:Xstart+condLength-1;
            end
            E=std(temp,0,2,'omitnan')./sqrt(size(temp,2)); %Standar error
            if c==1
                E=[E ;nan(10,1)];
            end
            if c==4 && group==10 ||  c==1 && group==4 ||  c==2 && group==4 ||  c==3 && group==4 || c==4 && group== 5 ||  c==4 && group== 6
                continue
            else
                
                %             [Pa, Li{loop}]= nanJackKnife(x,(y-bias)*scale,E',color,color+0.5.*abs(color-1),Opacity);
                yline(0)
            end
            
            
            if c==3
                
                %                 subplot(2,3,steeadystate)
                ss_data=nanmean(temp(1:10,:),1);
                %                 bar(loop,nanmean(y(1:10))*scale,'FaceColor',color,'BarWidth',0.9)
                hold on
                %                 errorbar(loop,nanmean(y(1:10))*scale,E(1),'LineStyle','none','color','k','LineWidth',2)
                for ss=1:size(X1,2)
                    %                     plot(loop-0.03,nanmean(temp(1:10,ss))*scale,'.','MarkerSize', 20, 'Color',[150 150 150]./255)
                    %                     text(loop,nanmean(temp(1 :10,ss))*scale,num2str(subj(ss)),'FontSize',14)
%                     data{xhat}.ss_ind(ss,loop)=nanmean(temp(1:10,ss))*scale;
                end
                
                
            end
            
            if c==4
                
                if dots==1
                    %                     subplot(2,3,5)
                    xl=[1 1 3 3];
                    %                         plot(xl(loop),abs(y(1)*scale) ,"o","MarkerSize",25, 'MarkerFaceColor',color); hold on;
                    %                         errorbar(xl(loop),abs(y(1)*scale),E(1),'LineStyle','none','color','k','LineWidth',2)
                    
                    if c==4 && group== 5 ||  c==4 && group== 6
                        continue
                    else
                        subplot(2,3,AE)
                        ea_data=temp(1,:);
                        %                             bar(loop,y(1)*scale,'FaceColor',color,'BarWidth',0.9)
                        hold on
                        %                             errorbar(loop,y(1)*scale,E(1),'LineStyle','none','color','k','LineWidth',2)
                        for ss=1:size(X1,2)
                            %                                 plot(loop-0.03,temp(1,ss)*scale,'.','MarkerSize', 15, 'Color',[150 150 150]./255)
                            %                                 text(loop,temp(1,ss)*scale,num2str(subj(ss)),'FontSize',14)
                            data{xhat}.epost_ind(ss,loop)=temp(1,ss)*scale;
                        end
                    end
                else
                    
                    if c==4 && group== 5 ||  c==4 && group== 6
                        continue
                    else
                        %                         subplot(2,3,AE)
                        if xhat==1
                            
                            subplot(1,2,xhat)
                            ea_data=temp(1,:);
                            bar(loop,abs(y(1)*scale),'FaceColor',color,'BarWidth',0.9)
                            data{xhat}.epost_mean(loop)=abs(y(1)*scale);
                            hold on
                            errorbar(loop,abs(y(1)*scale),E(1),'LineStyle','none','color','k','LineWidth',2)
                            data{xhat}.epost_se(loop)=E(1);
                            for ss=1:size(X1,2)
                                plot(loop-0.03,abs(temp(1,ss)*scale),'.','MarkerSize', 15, 'Color',[150 150 150]./255)
                                text(loop,abs(temp(1,ss)*scale),num2str(subj(ss)),'FontSize',14)
                                data{xhat}.epost_ind(ss,loop)=abs(temp(1,ss)*scale);
                            end
                        else
                            subplot(1,2,xhat)
                            ea_data=temp(1,:);
                            bar(loop,y(1)*scale,'FaceColor',color,'BarWidth',0.9)
                            data{xhat}.epost_mean(loop)=y(1)*scale;
                            hold on
                            errorbar(loop,y(1)*scale,E(1),'LineStyle','none','color','k','LineWidth',2)
                            data{xhat}.epost_se(loop)=E(1);
                            for ss=1:size(X1,2)
                                plot(loop-0.03,temp(1,ss)*scale,'.','MarkerSize', 15, 'Color',[150 150 150]./255)
                                text(loop,temp(1,ss)*scale,num2str(subj(ss)),'FontSize',14)
                                data{xhat}.epost_ind(ss,loop)=temp(1,ss)*scale;
                            end
                        end
                        
                    end
                    if group== 7 || group==8
                        
                        %                         subplot(2,3, timecourseE2)
                        %                         y(isnan(y))=[];
                        %                         E(isnan(E))=[];
                        %                         x_ea=1:length(y);
                        %                         [Pa, Li{loop}]= nanJackKnife(x_ea,(y-bias)*scale,E',color,color+0.5.*abs(color-1),Opacity);
                    else
                        
                        %                         subplot(2,3, timecourseE1)
                        %                         y(isnan(y))=[];
                        %                         E(isnan(E))=[];
                        %                         x_ea=1:length(y);
                        %                         [Pa, Li{loop}]= nanJackKnife(x_ea,(y-bias)*scale,E',color,color+0.5.*abs(color-1),Opacity);
                    end
                end
                
                %                 subplot(2,8,delta)
                %                 delta_data_ind= ss_data - ea_data;
                %                 delta_data=(nanmean(ss_data)-nanmean(ea_data));
                %
                %                 bar(loop,delta_data*scale,'FaceColor',color,'BarWidth',0.9)
                %                 hold on
                %                 errorbar(loop,delta_data*scale,std(delta_data_ind),'LineStyle','none','color','k','LineWidth',2)
                %                 for ss=1:size(X1,2)
                %                     plot(loop-0.03,delta_data_ind(ss)*scale,'.','MarkerSize', 15, 'Color',[150 150 150]./255)
                %                 end
                
                
            end
            
            
            
            Xstart=Xstart+condLength;
            
            hold on
            
            
        end
        
        %%
        
        
        
        %         subplot(2,3,timecourse)
        %         if group==1 || group==2 || group==3 || group==4 || group==9 || group==10
        %             if length(cond)==4
        %                 pp=patch([50 1000 1000 50],[-1.2 -1.2 1.2 1.2],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
        %                 uistack(pp,'bottom')
        %             else
        %
        %                 pp=patch([50 950 950 50],[-1.2 -1.2 1.2 1.2],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
        %                 uistack(pp,'bottom')
        %             end
        %             ylabel('X_{reactive}')
        % %             axis tight
        %         else
        %             if length(cond)==4
        %                 pp=patch([50 650 650 50],[-1.2 -1.2 1.2 1.2],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
        %                 uistack(pp,'bottom')
        %             else
        %                 pp=patch([50 600 600 50],[-1.2 -1.2 1.2 1.2],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
        %                 uistack(pp,'bottom')
        %             end
        %
        % %             ylabel('X_{learning}')
        %             axis tight
        %
        %         end
        %
        %         subplot(2,3,steeadystate)
        %         set(gca, 'XTick', 1:length(groups), 'XTickLabels', labels(groups))
        %         title('Steady State')
        %         subplot(2,3,AE)
        %         title('Early Post')
        %         set(gca, 'XTick', 1:length(groups), 'XTickLabels', labels(groups))
        %         subplot(2,8,delta)
        %         title('Delta')
        set(gca, 'XTick', 1:length(groups), 'XTickLabels', labels(groups))
        %
    end
end

% figure(1)
% subplot(2,3,AE)
% yl = get(gca,'YLim');
% subplot(2,3, timecourseE1)
% ylim(yl);
% subplot(2,3, timecourseE2)
% ylim(yl);

% figure(2)
% subplot(2,3,AE)
% yl = get(gca,'YLim');
% subplot(2,3, timecourseE1)
% ylim(yl);
% subplot(2,3, timecourseE2)
% ylim(yl);
%
% figure(1)
% subplot(2,3, timecourse)
% ylabel('X_{reactive}')
% set(gcf,'color','w')
% legend([Li{:}]',[labels(groups)])
% set(gcf,'renderer','painters')
%
% figure(2)
% subplot(2,3, timecourse)
% ylabel('X_{learning}')
% set(gcf,'color','w')
% legend([Li{:}]',[labels(groups)])
% set(gcf,'renderer','painters')

