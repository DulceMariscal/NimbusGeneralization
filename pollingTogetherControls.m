%% polling together the control TS and TR
load('PostData.mat')

YATR_X1=postData{1,1};
YATR_X2=postData{2,1};
YATS_X1=postData{1,2};
YATS_X2=postData{2,2};
CTR_X1=postData{1,3};
CTR_X2=postData{2,3};
CTS_X1=postData{1,4};
CTS_X2=postData{2,4};

YATR_X1=YATR_X1(1:200,:);
YATR_X2=YATR_X2(1:200,:);
YATS_X1=YATS_X1(1:200,:);
YATS_X2=YATS_X2(1:200,:);
CTR_X1=CTR_X1(1:200,:);
CTR_X2=CTR_X2(1:200,:);
CTS_X1=CTS_X1(1:200,:);
CTS_X2=CTS_X2(1:200,:);

X1=[];
X2=[];
X1{1}=[YATR_X1 CTR_X1];
X1{2}=[YATS_X1 CTS_X1];

X2{1}=[YATR_X2 CTR_X2];
X2{2}=[YATS_X2 CTS_X2];

% subj1=[1:7]; %all Data
subj1=[1:2 5:7]; %Gelsy pick
% subj1=[2 3 5 6 7];

% subj2=[1:6 8:14]; %all data

% subj2=[2 4 9 11 12];
% subj2=[2 6 8 9 13 14 ]; %gelsy pick
subj2=[2 6 8 9 14 ]; %gelsy pick 5

X1{1}=X1{1}(:,subj1);
X2{1}=X2{1}(:,subj1);


X1{2}=X1{2}(:,subj2);
X2{2}=X2{2}(:,subj2);


ini=[1];
strides=[200];
sz=[200];

scale=[];
loop=0;
cond={'Post1'};
Opacity=0.5;

groups=[1 2];
% labels={'TS','TS'};
labels={'YA', 'OA'}
dots=1;

% data{1}.epost_ind=nan(10,length(groups));
% data{2}.epost_ind=nan(10,length(groups));

% figure
legend('AutoUpdate','off')
for group=groups
    
    if group==1
    subj=subj1;
    else
     subj=subj2;   
    end
    loop=loop+1;
    for xhat=1:2
        
        if xhat==1
%             figure(1)
            X=X1{group};
            timecourse=1:2;
            shortTimecourse=4;
            AE=6;
            
        else
%             figure(2)
            X=X2{group};
            shortTimecourse=4;
            timecourse=1:2;
            AE=6;
           
            
        end
        
        if group==1
            color=[0.3010 0.7450 0.9330];
        else
             color=[0.6350 0.0780 0.1840];
        end
        Xstart=680;
        for c=1:length(cond)
            temp=[];
            
            
%             subplot(2,3,timecourse)
            hold on
            temp=nan(strides(c),size(X,2));
            
            temp(1:sz(c),:)=movmean(X(ini(c):strides(c),:),5,'omitnan'); %moving average of 5
            
            y=nanmean(temp,2)'; %across subjects mean
            if c==1
                
                bias=nanmean(y);
            end
            
            
            if max(abs(y))>1  %To scale the hidden state to be max 1
                
                scale=1/1.84;%(1/max(abs(y)));
                
                
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
                
                postData{loop}=temp;
            else
                x=Xstart:Xstart+condLength-1;
            end
            E=std(temp,0,2,'omitnan')./sqrt(size(temp,2)); %Standar error
%             [Pa, Li{loop}]= nanJackKnife(x,(y-bias)*scale,E',color,color+0.5.*abs(color-1),Opacity);
            yline(0)
            ylim([-1 1.2])
            
%             subplot(2,3, 4)
            y(isnan(y))=[];
            E(isnan(E))=[];
            x_ea=1:length(y);
%             [Pa, Li{loop}]= nanJackKnife(x_ea,(y-bias)*scale,E',color,color+0.5.*abs(color-1),Opacity);
            
            
            
        end

        if dots==1
%             subplot(2,3,5)
%             xl=[1 1 2];
%             plot(xl(loop),abs(y(1)*scale) ,"o","MarkerSize",25, 'MarkerFaceColor',color); hold on;
%             errorbar(xl(loop),abs(y(1)*scale),E(1),'LineStyle','none','color','k','LineWidth',2)
        end
        
        
        if c==1
            %             subplot(2,3,AE)
            
            if xhat==1
                
                figure(1)
                subplot(1,2,xhat)
                ea_data=temp(1,:);
                bar(loop,abs(y(1)*scale),'FaceColor',color,'BarWidth',0.9)
                data{xhat}.epost_mean(loop)=abs(y(1)*scale);
                hold on
                errorbar(loop,abs(y(1)*scale),E(1),'LineStyle','none','color','k','LineWidth',2)
                data{xhat}.epost_se(loop)=E(1);
                for ss=1:size(X,2)
                    plot(loop-0.03,abs(temp(1,ss)*scale),'.','MarkerSize', 15, 'Color',[150 150 150]./255)
                    data{xhat}.epost_ind(ss,loop)=abs(temp(1,ss)*scale);
                    text(loop,abs(temp(1,ss)*scale),num2str(subj(ss)),'FontSize',14)
                    
                end
                
            else
                figure(1)
                subplot(1,2,xhat)
                ea_data=temp(1,:);
                bar(loop,y(1)*scale,'FaceColor',color,'BarWidth',0.9)
                data{xhat}.epost_mean(loop)=y(1)*scale;
                hold on
                errorbar(loop,y(1)*scale,E(1),'LineStyle','none','color','k','LineWidth',2)
                data{xhat}.epost_se(loop)=E(1);
                for ss=1:size(X,2)
                    plot(loop-0.03,temp(1,ss)*scale,'.','MarkerSize', 15, 'Color',[150 150 150]./255)
                    data{xhat}.epost_ind(ss,loop)=temp(1,ss)*scale;
                    text(loop,temp(1,ss)*scale,num2str(subj(ss)),'FontSize',14)
                    
                end
            
            
            end
        end
        
        
        
        Xstart=Xstart+condLength;
        
        hold on
        
        
    end
    
    %%
    
%     subplot(2,8,timecourse)
%     if group==1 || group==2 || group==3 || group==4 || group==9 || group==10
%         if length(cond)==4
%             pp=patch([50 1000 1000 50],[-1.2 -1.2 1.2 1.2],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
%             uistack(pp,'bottom')
%         else
%             
%             pp=patch([50 950 950 50],[-1.2 -1.2 1.2 1.2],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
%             uistack(pp,'bottom')
%         end
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
%     
%     subplot(2,8,steeadystate)
%     set(gca, 'XTick', 1:length(groups), 'XTickLabels', labels(groups))
%     title('Steady State')
%     subplot(2,3,AE)
%     title('Early Post')
% %     set(gca, 'XTick', [1 3], 'XTickLabels',  labels(groups))
% 
% %     subplot(2,8,delta)
% %     title('Delta')
% %     set(gca, 'XTick', 1:length(groups), 'XTickLabels', labels(groups))
%     subplot(2,3,5)
%     title('Early Post')
%     set(gca, 'XTick', 1:length(groups), 'XTickLabels',  labels(groups))
    
end
set(gcf,'color','w')
% legend([Li{:}]',[labels(groups)])
% subplot(2,3,1:2)
% title('Poll data controls training and controls testing')
