%%Traces from example subject to show how data is summarized
%% Load data
% load('.../GYAAT_01.mat');

%% Loading data for Boyan 
% we need to load to expData files due to the problems with sensor 8 box 1
% after trial 1

load('NimbG_Boyan_RPER.mat')
expData2=expData;
load('NimG_Boyan.mat')

%% Align it
% conds={'TM Base','Adap','Post adapt','Shor Split'};
conds={'OG base: no Nimbus','TM Nimbus: Nimbus off 3','Short Split +',...
    'Short Split -','OG nimbus: Nimbus off','Adaptation',...
    'OG post: No nimbus','Washout: Nimbus off'};

% condlegend={'TM base','Early Adapt','Late Adapt','Early Post','Late Post','Short Pos','Short Neg'};
condlegend=conds;
events={'RHS','LTO','LHS','RTO'};
% condlegend={'Early Adapt','Short Pos','Short Neg'};
alignmentLengths=[16,32,16,32];
% muscle={'MG','RF','VL','SEMT','TA'};
% muscle={'MG','LG','PER'};
muscle={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU','HIP'};
% muscle={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'ADM'};
% muscle={'TA', 'PER', 'SOL', 'LG','MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF'};
lm=1:2:35;
late=0;
if late==1
%     condlegend={'No Nimbus','TM: Nimbus off 3',...
%         'OG Nimbus: Nimbus off','Adaptation',...
%         'Generalization Late','Washout Late'};
    condlegend={'No Nimbus','OG Nimbus: Nimbus off','OG post: No nimbus'};
else
    condlegend={'OG nimbus: Nimbus off','Short Split +','Short Split -',...
        'Generalization','Washout'};
    
end
% for late=1:2
fh=figure('Units','Normalized');
% load(['SCB0',num2str(s), '.mat'])

for m=1:length(muscle)
    
    % OG base: no Nimbus
%     load('NimbG_Boyan_RPER.mat')
    RBaseoff=expData2.getAlignedField('procEMGData',conds(1),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
    LBaseoff=expData2.getAlignedField('procEMGData',conds(1),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
%     load('NimG_Boyan.mat')
    % TM Nimbus: Nimbus off
    RTMBaseoff=expData.getAlignedField('procEMGData',conds(2),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
    LTMBaseoff=expData.getAlignedField('procEMGData',conds(2),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
    
    %Short Split +
    RPosi=expData.getAlignedField('procEMGData',conds(3),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
    LPosi=expData.getAlignedField('procEMGData',conds(3),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
    
    %Short Split +
    RNeg=expData.getAlignedField('procEMGData',conds(4),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
    LNeg=expData.getAlignedField('procEMGData',conds(4),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
    
    %OG nimbus
    RBase=expData.getAlignedField('procEMGData',conds(5),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
    LBase=expData.getAlignedField('procEMGData',conds(5),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
    
    % Adaptation
    RAdap=expData.getAlignedField('procEMGData',conds(6),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
    LAdap=expData.getAlignedField('procEMGData',conds(6),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
    
    % OG post: No nimbus
    RPost=expData.getAlignedField('procEMGData',conds(7),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
    LPost=expData.getAlignedField('procEMGData',conds(7),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
    
    %Washout
    RPostWash=expData.getAlignedField('procEMGData',conds(8),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
    LPostWash=expData.getAlignedField('procEMGData',conds(8),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
    
    %% Create plots
    % close all;
    poster_colors;
    colorOrder=[p_red; p_orange; p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]];
    condColors=colorOrder;
    
    % fh=figure('Units','Normalized','Position',[0 0 .45 .2]);
    
    % norm2=max(allmuscle.Data);
    % allmuscle.Data=bsxfun(@rdivide,allmuscle.Data,norm2);
    
    for l=1:2
        switch l
            case 1
                
                %Late
                Nimbusoff=RBaseoff.getPartialStridesAsATS(find(RBaseoff.Data(180-40:180)));
                TMbase=RTMBaseoff.getPartialStridesAsATS(find(RTMBaseoff.Data(end-40:end)));
                Base=RBase.getPartialStridesAsATS(find(RBase.Data(end-40:end)));
                Adaptation=RAdap.getPartialStridesAsATS(find(RAdap.Data(end-40:end)));
                Washout_Late=RPostWash.getPartialStridesAsATS(find(RPostWash.Data(end-40:end)));
                Post_Late=RPost.getPartialStridesAsATS(find(RPost.Data(end-40:end)));
                
                %Early
                Post=RPost.getPartialStridesAsATS(find(RPost.Data(1:30)));
                Pos=RPosi.getPartialStridesAsATS(find(RPosi.Data(1:30)));
                Neg=RNeg.getPartialStridesAsATS(find(RNeg.Data(1:30)));
                Washout=RPostWash.getPartialStridesAsATS(find(RPostWash.Data(1:30)));
                
                
                
                tit=['R' muscle{m}];
            case 2
                
                %Late
                Nimbusoff=LBaseoff.getPartialStridesAsATS(find(LBaseoff.Data(180-40:180)));
                TMbase=LTMBaseoff.getPartialStridesAsATS(find(LTMBaseoff.Data(end-40:end)));
                Base=LBase.getPartialStridesAsATS(find(LBase.Data(end-40:end)));
                Adaptation=LAdap.getPartialStridesAsATS(find(LAdap.Data(end-40:end)));
                Post_Late=LPost.getPartialStridesAsATS(find(LPost.Data(end-40:end)));
                Washout_Late=LPostWash.getPartialStridesAsATS(find(LPostWash.Data(end-40:end)));
                
                %Early
                Pos=LPosi.getPartialStridesAsATS(find(LPosi.Data(1:30)));
                Neg=LNeg.getPartialStridesAsATS(find(LNeg.Data(1:30)));
                Post=LPost.getPartialStridesAsATS(find(LPost.Data(1:30)));
                Washout=LPostWash.getPartialStridesAsATS(find(LPostWash.Data(1:30)));
                
                tit=['L' muscle{m}];
                
        end
        %     allmuscle=EMG.getPartialStridesAsATS(1:size(EMG.Data,3))
        
        norm2=nanmean(nanmax(squeeze(Base.Data)));
        %Late
        Nimbusoff.Data=bsxfun(@rdivide,Nimbusoff.Data,norm2);
        TMbase.Data=bsxfun(@rdivide,TMbase.Data,norm2);
        Base.Data=bsxfun(@rdivide,Base.Data,norm2);
        Adaptation.Data=bsxfun(@rdivide,Adaptation.Data,norm2);
        Post_Late.Data=bsxfun(@rdivide,Post_Late.Data,norm2);
        Washout_Late.Data=bsxfun(@rdivide,Washout_Late.Data,norm2);
        
        %             Early
        Pos.Data=bsxfun(@rdivide,Pos.Data,norm2);
        Neg.Data=bsxfun(@rdivide,Neg.Data,norm2);
        Post.Data=bsxfun(@rdivide,Post.Data,norm2);
        Washout.Data=bsxfun(@rdivide,Washout.Data,norm2);
        
        condColors=colorOrder;
        % ph=[];
        ph1=[];
        prc=[16,84];
        MM=sum(alignmentLengths);
        M=cumsum([0 alignmentLengths]);
        xt=sort([M,M(1:end-1)+[diff(M)/2]]);
        phaseSize=8;
        xt=[0:phaseSize:MM];
        %xt=[0:8:MM];s
        fs=16; %FontSize
        
        
        ph=subplot(5,6,lm(m)+l-1);
        %     ph=subplot(1,2,l);
        set(gcf,'color','w');
        %     set(ph,'Position',[.07 .48 .35 .45]);
        hold on
        
        
        if late==1
%             title('Late Phases')
            Nimbusoff.plot(fh,ph,condColors(1,:),[],0,[-49:0],prc,true);
%             TMbase.plot(fh,ph,condColors(2,:),[],0,[-49:0],prc,true);
            Base.plot(fh,ph,condColors(5,:),[],0,[-49:0],prc,true);
%             Adaptation.plot(fh,ph,condColors(6,:),[],0,[-49:0],prc,true);
            Post_Late.plot(fh,ph,condColors(7,:),[],0,[-49:0],prc,true);
%             Washout_Late.plot(fh,ph,condColors(8,:),[],0,[-49:0],prc,true);
        else
            %             fh2=figure('Units','Normalized');
%             title('Early Phases')
            Base.plot(fh,ph,condColors(5,:),[],0,[-49:0],prc,true);
            Pos.plot(fh,ph,condColors(6,:),[],0,[-49:0],prc,true);
            Neg.plot(fh,ph,condColors(4,:),[],0,[-49:0],prc,true);
            Post.plot(fh,ph,condColors(7,:),[],0,[-49:0],prc,true);
            Washout.plot(fh,ph,condColors(8,:),[],0,[-49:0],prc,true);
        end
        axis tight
        ylabel('')
        ylabel(tit)
        %     set(ph,'YTick',[0,1],'YTickLabel',{'0%','100%'})
        grid on
        ll=findobj(ph,'Type','Line');
        %     legend(ll(end:-1:4-3),conds{1:5})
        %     title([subject,' late'])
        %
        % %     %Add rectangles quantifying activity
        % % %     for j=1:3
        % % %         k=3:4;
        % % %         ph1(j)=axes;
        % % %         set(ph1(j),'Position',[.07 .25+(j-1)*-.11 .35 .09]);
        % % %         drawnow
        % % %         pause(1)
        % % %         da=randn(1,12);
        % % %         gamma=.5;
        % % %         ex1=condColors(j,:);
        % % %         map=niceMap(ex1,gamma);
        % % %         switch j
        % % %             case 1
        % % %             aux=nanmedian(B.Data,3)';
        % % %             tt='B';
        % % %             case 2
        % % %             aux=nanmedian(A.Data,3)';
        % % %             tt='lA';
        % % %             case 3
        % % %             aux=1*(nanmedian(A.Data,3)'-nanmedian(B.Data,3)') +.5*max(nanmedian(B.Data,3));
        % % %             figuresColorMap;
        % % %             tt='lA_B';
        % % %         end
        % % %         clear aux2
        % % %         for k=1:length(xt)-1
        % % %             aux2(k)=mean(aux(xt(k)+1:xt(k+1)));
        % % %         end
        % % %         I=image(size(map,1)*aux2/max(nanmedian(B.Data,3)));
        % % %         I.Parent.Colormap=flipud(map);
        % % %         rectangle('Position',[.5 .5 12 1],'EdgeColor','k')
        % % %         set(ph1(j),'XTickLabel','','YTickLabel','','XTick','','YTick','')
        % % %         text(-.4-.1*(j-1)^2.6,1,tt,'Clipping','off','FontSize',14,'FontWeight','bold')
        % % %     end
        % % %     drawnow
        % % %     %
        % % %
        % % %
        % % %     axes(ph)
        % % %     ll=findobj(ph,'Type','Line');
        % % %     set(ll,'LineWidth',3)
        % % %     set(ph,'FontSize',fs,'YTickLabel','','XTickLabel','','XTick',xt,'YTick','')
        % % %     a=axis;
        % % %     yOff=a(3)-.5*(a(4)-a(3));
        % % %     %Add labels:
        % % %     text(.25*2*phaseSize,yOff,'DS','Clipping','off','FontSize',fs)
        % % %     text(1.15*2*phaseSize,yOff,{'STANCE'},'Clipping','off','FontSize',fs)
        % % %     text(3.225*2*phaseSize,yOff,'DS','Clipping','off','FontSize',fs)
        % % %     text(4.25*2*phaseSize,yOff,{'SWING'},'Clipping','off','FontSize',fs)
        % % %     axis(a)
        % % %     hold on
        % % %     yOff=a(3)-.05*(a(4)-a(3));
        % % %     %Add lines:
        % % %     plot([.1 .9]*2*phaseSize,[1 1]*yOff,'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
        % % %     plot([1.1 2.9]*2*phaseSize,[1 1]*yOff,'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
        % % %     plot([3.1 3.9]*2*phaseSize,[1 1]*yOff,'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
        % % %     plot([4.1 5.9]*2*phaseSize,[1 1]*yOff,'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
        % % % %     legend(ll(end:-1:end-1),{'Baseline','Adaptation'})
        % % %
        % % %     set(fh,'Position',[0 0 .45 .2])
        % end
        %     saveFig(fh,'./',['Fig1B_' num2str(l)],1)
    end
    % legend(ll(end:-1:1),condlegend{:})
end
if late==1
    title('Late Phases')
    
else
    %             fh2=figure('Units','Normalized');
    title('Early Phases')
end
legend(ll(end:-1:1),condlegend{:})
% end%%
