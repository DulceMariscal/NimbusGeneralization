%%Traces from example subject to show how data is summarized
%% Load data
% load('/Volumes/Users/Dulce/R01_Nimbus2021/VROG_Devon/VrG_Devon.mat')

%% Align it

conds={'OG base','TM base','Pos Short','Neg Short',...
    'TM tied 1',...
    'Adaptation','OG post','TM post'};


events={'RHS','LTO','LHS','RTO'};

alignmentLengths=[16,32,16,32];

muscle={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU','HIP'};
% muscle={'HIP'};
lm=1:2:35;
late=0;
baseOnly=0;
if late==1
    
    if baseOnly==1
        
        condlegend={'OGbase_{late}','TMbaseVR_{late}','TMBase_{late}'};
    else
        condlegend={'OGbase_{late}','TMbaseVR_{late}','TMtied_{late}','Adaptation_{late}',...
            'OGpost_{late}','TMpost_{late}'};
    end
    
else
    condlegend={'TMbaseVR_{late}','Pos Short','Neg Short',...
        'OGpost_{early}','TMpost_{early}'};
    
end

fh=figure('Units','Normalized');


for m=1:length(muscle)
    
    %OG base No VR
    ROGBase=expData.getAlignedField('procEMGData',conds(1),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
    LOGBase=expData.getAlignedField('procEMGData',conds(1),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
    
    %TM base VR
    RTMBaseVR=expData.getAlignedField('procEMGData',conds(2),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
    LTMBaseVR=expData.getAlignedField('procEMGData',conds(2),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
    
    %Short Split + No VR
    RPosi=expData.getAlignedField('procEMGData',conds(3),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
    LPosi=expData.getAlignedField('procEMGData',conds(3),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
    
    %Short Split - No VR
    RNeg=expData.getAlignedField('procEMGData',conds(4),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
    LNeg=expData.getAlignedField('procEMGData',conds(4),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
    
    %TM base no VR
    RTMBase=expData.getAlignedField('procEMGData',conds(5),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
    LTMBase=expData.getAlignedField('procEMGData',conds(5),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
    
    %Adaptation VR
    RAdap=expData.getAlignedField('procEMGData',conds(6),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
    LAdap=expData.getAlignedField('procEMGData',conds(6),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
    
    %OG post NO VR
    ROGPost=expData.getAlignedField('procEMGData',conds(7),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
    LOGPost=expData.getAlignedField('procEMGData',conds(7),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
    
    %TMpost VR
    RTMPost=expData.getAlignedField('procEMGData',conds(8),events,alignmentLengths).getPartialDataAsATS({['R' muscle{m}]});
    LTMPost=expData.getAlignedField('procEMGData',conds(8),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle{m}]});
    
    %% Create plots
    % close all;
    poster_colors;
    colorOrder=[p_red; p_orange; p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]];
    condColors=colorOrder;
    
    
    for l=1:2
        switch l
            case 1
                
                %Late
                OGbase_late=ROGBase.getPartialStridesAsATS(find(ROGBase.Data(end-40:end)));
                TMbaseVR_late=RTMBaseVR.getPartialStridesAsATS(find(RTMBaseVR.Data(end-40:end)));
                TMBase_late=RTMBase.getPartialStridesAsATS(find(RTMBase.Data(end-40:end)));
                Adaptation_late=RAdap.getPartialStridesAsATS(find(RAdap.Data(end-40:end)));
                TMpost_Late=RTMPost.getPartialStridesAsATS(find(RTMPost.Data(end-40:end)));
                OGPost_Late=ROGPost.getPartialStridesAsATS(find(ROGPost.Data(end-40:end)));
                
                %Early
                OGPost_early=ROGPost.getPartialStridesAsATS(find(ROGPost.Data(1:30)));
                Pos=RPosi.getPartialStridesAsATS(find(RPosi.Data(1:30)));
                Neg=RNeg.getPartialStridesAsATS(find(RNeg.Data(1:30)));
                TMPost_early=RTMPost.getPartialStridesAsATS(find(RTMPost.Data(1:30)));
                
                
                
                tit=['R' muscle{m}];
            case 2
                
                %Late
                OGbase_late=LOGBase.getPartialStridesAsATS(find(LOGBase.Data(end-40:end)));
                TMbaseVR_late=LTMBaseVR.getPartialStridesAsATS(find(LTMBaseVR.Data(end-40:end)));
                TMBase_late=LTMBase.getPartialStridesAsATS(find(LTMBase.Data(end-40:end)));
                Adaptation_late=LAdap.getPartialStridesAsATS(find(LAdap.Data(end-40:end)));
                
                %                 if m==14
                %
                %                 else
                OGPost_Late=LOGPost.getPartialStridesAsATS(find(LOGPost.Data(end-40:end)));
                TMpost_Late=LTMPost.getPartialStridesAsATS(find(LTMPost.Data(end-40:end)));
                %                 end
                
                
                
                %Early
                Pos=LPosi.getPartialStridesAsATS(find(LPosi.Data(1:30)));
                Neg=LNeg.getPartialStridesAsATS(find(LNeg.Data(1:30)));
                OGPost_early=LOGPost.getPartialStridesAsATS(find(LOGPost.Data(1:30)));
                TMPost_early=LTMPost.getPartialStridesAsATS(find(LTMPost.Data(1:30)));
                %                 if m==14
                %
                %                 else
                %
                %                 end
                
                
                tit=['L' muscle{m}];
                
        end
        
        norm2=nanmean(nanmax(squeeze(TMbaseVR_late.Data)));
        
        %Late
        OGbase_late.Data=bsxfun(@rdivide,OGbase_late.Data,norm2);
        TMbaseVR_late.Data=bsxfun(@rdivide,TMbaseVR_late.Data,norm2);
        TMBase_late.Data=bsxfun(@rdivide,TMBase_late.Data,norm2);
        Adaptation_late.Data=bsxfun(@rdivide,Adaptation_late.Data,norm2);
        OGPost_Late.Data=bsxfun(@rdivide,OGPost_Late.Data,norm2);
        TMpost_Late.Data=bsxfun(@rdivide,TMpost_Late.Data,norm2);
        
        %             Early
        Pos.Data=bsxfun(@rdivide,Pos.Data,norm2);
        Neg.Data=bsxfun(@rdivide,Neg.Data,norm2);
        OGPost_early.Data=bsxfun(@rdivide,OGPost_early.Data,norm2);
        TMPost_early.Data=bsxfun(@rdivide,TMPost_early.Data,norm2);
        %
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
            if baseOnly==1
                OGbase_late.plot(fh,ph,condColors(1,:),[],0,[-49:0],prc,true);
                TMbaseVR_late.plot(fh,ph,condColors(2,:),[],0,[-49:0],prc,true);
                TMBase_late.plot(fh,ph,condColors(5,:),[],0,[-49:0],prc,true);
            else
                OGbase_late.plot(fh,ph,condColors(1,:),[],0,[-49:0],prc,true);
                TMbaseVR_late.plot(fh,ph,condColors(2,:),[],0,[-49:0],prc,true);
                TMBase_late.plot(fh,ph,condColors(5,:),[],0,[-49:0],prc,true);
                Adaptation_late.plot(fh,ph,condColors(6,:),[],0,[-49:0],prc,true);
                OGPost_Late.plot(fh,ph,condColors(7,:),[],0,[-49:0],prc,true);
                TMpost_Late.plot(fh,ph,condColors(8,:),[],0,[-49:0],prc,true);
                
                
            end
            %
        else
            TMbaseVR_late.plot(fh,ph,condColors(2,:),[],0,[-49:0],prc,true);
            Pos.plot(fh,ph,condColors(9,:),[],0,[-49:0],prc,true);
            Neg.plot(fh,ph,condColors(4,:),[],0,[-49:0],prc,true);
            OGPost_early.plot(fh,ph,condColors(7,:),[],0,[-49:0],prc,true);
            TMPost_early.plot(fh,ph,condColors(8,:),[],0,[-49:0],prc,true);
        end
        axis tight
        ylabel('')
        ylabel(tit)
        %     set(ph,'YTick',[0,1],'YTickLabel',{'0%','100%'})
        grid on
        ll=findobj(ph,'Type','Line');
        
    end
end
if late==1
    title('Late Phases')
    
else
    title('Early Phases')
end
legend(ll(end:-1:1),condlegend{:})
% end%%
set(gcf,'color','w');