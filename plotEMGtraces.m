function fh=plotEMGtraces(expData,conds,muscle,late,strides)
%% Plot the EMG ttraces for the Nimbus generalization project
%
%INPUTS: 
    %expData - experimentData file, we are going to
    %use a timeseries approach
    %conds - Conditions that you want to plot ex: 'TM base'
    %muscle - list of the muscles that you want to plot 
    %late - 1 if you want to plot the last strides 0 if yo uwant to plot
    %tte initial strides 
    %strides - number of strides that you want to plot 
    
%OUTPUT:
    % fh - figure handle 
    
%EXAMPLE: 
    %fh=plotEMGtraces(expData,{'TM base'},{'TA'},1,40);
    %This will plot the average of the last 40 strides of for the TA muscle
    %during treadmill baseline 
%% Plot config
%this is the setting for a 5x6 subplot
row=5;
colum=6;

%% Set period to plot
% late=0;
% baselate=1;
% missing = [];
%% Align iat

% muscle={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU','HIP'};

lm=1:2:2*length(muscle)+1;
if late==1
    %     strides=40;
    %     if baselate==1
    %         conds={'OG base','TM tied 1','TR Base'};
    % %         condlegend=strcat(repmat(conds,1,1),'_{late}');
    %     else
    %         conds={'OG base','TM tied 1','TR Base','Adaptation',...
    %             'Post 1','Post 2'};
    %
    %     end
    condlegend=strcat(repmat(conds,1,1),'_{late}');
else
    %     strides=30;
    %     conds={'TR base','Pos short','Neg Short',...
    %         'Post 1','Post 2'};
    %     condlegend={'TRbase','Pos Short','Neg Short',...
    %         'Post1','Post2'};
    condlegend=strcat(repmat(conds,1,1),'_{early}');
end


fh=figure('Units','Normalized');
poster_colors;
colorOrder=[p_red; p_orange; p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]];
condColors=colorOrder;

ph1=[];
prc=[16,84];
alignmentLengths=[16,32,16,32];
MM=sum(alignmentLengths);
M=cumsum([0 alignmentLengths]);
xt=sort([M,M(1:end-1)+[diff(M)/2]]);
phaseSize=8;
xt=[0:phaseSize:MM];

fs=16; %FontSize


set(gcf,'color','w')
hold on

for m=1:length(muscle)
    leg={'R','L'};
    for l=1:2
        for c=1:length(conds)
            
            
            if l==1
                data=getDataEMGtraces(expData,muscle{m},conds(c),leg{l},late,strides);
                norm=getDataEMGtraces(expData,muscle{m},{'TR base'},leg{l},1,40);
                tit=['R' muscle{m}];
            elseif l==2
                data=getDataEMGtraces(expData,muscle{m},conds(c),leg{l},late,strides);
                norm=getDataEMGtraces(expData,muscle{m},{'TR base'},leg{l},1,40);
                tit=['L' muscle{m}];
            end
            norm=nanmean(nanmax(squeeze(norm.Data)));
            data.Data=bsxfun(@rdivide,data.Data,norm);
            ph=subplot(row,colum,lm(m)+l-1);
            data.plot(fh,ph,condColors(c,:),[],0,[-49:0],prc,true);
            
            
        end
        axis tight
        ylabel('')
        ylabel(tit)
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



end