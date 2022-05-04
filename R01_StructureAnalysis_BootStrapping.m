clear all

poster_colors;
colorOrder=[p_red; p_orange; p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]];

sqrtFlag=false;
loop=0;
Li=[];
% group=2;
labels={'OA_{TR}','OA_{TS}','Stroke_{TR}','YA_{TR}','CTR','CTS','NTR','NTS','YA_{TS}','YA'};
groups=[1 3 10];
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
        subj= [1:12];
        load('OA_TR_fixDandC_160322T155119.mat')
        color=[0.9290 0.6940 0.1250];
        
    elseif group==2
        fname= 'dynamicsData_AUF_s7.h5';
        subj= [2 4 6];
        load('OA_TS_fixCandD_Adaptation070422T142847.mat')
        color=[0.4940 0.1840 0.5560];
        
    elseif group==3
        fname='dynamicsData_Stroke.h5';
        subj=[1:3 5:13];
%         load('Stroke_TR_fixCandD_040422T114934.mat')
        load('OA_TR_fixDandC_160322T155119.mat')
        color= [0.4660 0.6740 0.1880];
        
    elseif group==4
        fname='dynamicsData_ATR_V4.h5';
        subj=[1:4];
        load('YA_TR_fixDandCV4_20220316T114557.mat')
        color=[0 0.4470 0.7410];
    elseif group==5
        fname='dynamicsData_CTR.h5';
        subj=[2:4];
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
        color=p_fade_blue;
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
    for bot=1:100
       
        
        
        p = datasample(subj,length(subj),'Replace',true);
        i=i+1;
        subjIdx=[p];%
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
            figure(2)
            subplot(2,1,1)
            hold on
            plot( movmean(X2asym(:,1),binwith))
            
            subplot(2,1,2)
            plot(movmean(X2asym(:,2),binwith))
            hold on
            
        end
        
        
    end
    %%
    
    figure(1)
%     cond={'TMbase','Adaptation','Post1'};
%     if group==1 || group==2 || group==3 || group==4
%         strides=[50 950 1140];
%         ini=[1 51 951];
%         sz=[50 900 190];
%     else
%         strides=[50 600 800];
%         ini=[1 51 601];
%         sz=[50 550 200];
%         
%     end

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
    
    Xstart=1;
    for c=1:length(cond)
        temp=[];
        
        
        subplot(2,6,1:5)
        hold on
        temp=nan(strides(c),size(X1,2));
        temp(1:sz(c),:)=movmean(X1(ini(c):strides(c),:),5,'omitnan'); %moving average of 5
        y=[];
        y=nanmean(temp,2)'; %across subjects mean
        
        if max(abs(y))>1  %To scale the hidden state to be max 1
            
            if c==4
            
                scale=1;
            else
                
            scale=1; %(1/max(abs(y)));
            end
            
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
%         x=Xstart:Xstart+condLength-1;
        E=std(temp,0,2,'omitnan');%./sqrt( size(temp,2)); %Standar error
        [Pa, Li{loop}]= nanJackKnife(x,y*scale,E',color,color+0.5.*abs(color-1),Opacity);
        yline(0)
        
        if c==4
            subplot(2,6,6)
            bar(loop,y(1)*scale,'FaceColor',color,'BarWidth',0.9)
            hold on
            errorbar(loop,y(1)*scale,E(1),'LineStyle','none','color','k','LineWidth',2)
            for ss=1:size(X1,2)
                plot(loop-0.03,temp(1,ss)*scale,'.','MarkerSize', 15, 'Color',[150 150 150]./255)
            end
            
        end
        
        %         bar(plotHandles(p),xval(:,i),squeeze(plotData(i,p,:)),'FaceColor',colors(i,:),'BarWidth',0.2)
        %         errorbar(plotHandles(p),xval(:,i),squeeze(plotData(i,p,:)),squeeze(varData(i,p,:)),'LineStyle','none','color','k','LineWidth',2)
        
        
        subplot(2,6,7:11)
        hold on
        temp=nan(strides(c),size(X2,2)); %moving average of 5
        temp(1:sz(c),:)=movmean(X2(ini(c):strides(c),:),5,'omitnan'); %across subjects mean
        y=nanmean(temp,2)';
        
        if max(abs(y))>1  %To scale the hidden state to be max 1
            if c==4
                scale2=1;
            else
            scale2=1 ;%(1/max(abs(y)));
            end
            
        end
        
        if isempty(scale2)
            scale2=1;
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
%         x=Xstart:Xstart+condLength-1;
        E=std(temp,0,2,'omitnan');%./sqrt( size(temp,2)); %Standar error
        [Pa, Li{loop}]= nanJackKnife(x,y*scale2,E',color,color+0.5.*abs(color-1),Opacity);
        yline(0)
        
        if c==4
            subplot(2,6,12)
            bar(loop,y(1)*scale2,'FaceColor',color,'BarWidth',.9)
            hold on
            errorbar(loop,y(1)*scale2,E(1),'LineStyle','none','color','k','LineWidth',2)
            
            for ss=1:size(X1,2)
                plot(loop-0.03,temp(1,ss)*scale2,'.','MarkerSize', 15, 'Color',[150 150 150]./255)
            end
        end
        
        Xstart=Xstart+condLength;
        
        hold on
        
        
    end
    %%
    
    subplot(2,6,1:5)
%     if group==1 || group==2 || group==3 || group==4
%         pp=patch([50 950 950 50],[-1.2 -1.2 1.2 1.2],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
%         uistack(pp,'bottom')
%         ylabel('X_{reactive}')
%         axis tight
%     else
%         pp=patch([50 600 600 50],[-1.2 -1.2 1.2 1.2],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
%         uistack(pp,'bottom')
%         ylabel('X_{reactive}')
%         axis tight
%         
%     end

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
    
    
    subplot(2,6,7:11)
%     if group==1 || group==2 || group==3 || group==4
%         pp=patch([50 950 950 50],[-1.2 -1.2 1.2 1.2],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
%         uistack(pp,'bottom')
%         ylabel('X_{reactive}')
%         axis tight
%     else
%         pp=patch([50 600 600 50],[-1.2 -1.2 1.2 1.2],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
%         uistack(pp,'bottom')
%         ylabel('X_{reactive}')
%         axis tight
%         
%     end
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
    
    subplot(2,6,6)
    set(gca, 'XTick', 1:length(groups), 'XTickLabels', labels(groups))
    subplot(2,6,12)
    set(gca, 'XTick', 1:length(groups), 'XTickLabels', labels(groups))
end
set(gcf,'color','w')
legend([Li{:}]',[labels(groups)])