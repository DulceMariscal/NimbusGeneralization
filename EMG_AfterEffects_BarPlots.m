clc

groups={'CTR','CTS','NTR','NTS'};
groups={'CTR','CTS'};
biasremove=1;

Epoch={'Post1_{Early}','Ref:','Post1-Adapt_{SS}'};
ep=1;
figure
for g=1:2
    xx=[1 2 6 7];
    load(['Norm_', groups{g},'_',num2str(biasremove)])
    ss=0;
    temp=contains(IndvTable.Epoch,Epoch{ep});
    bar(xx(g), meanTable.(groups{g})(temp))
for s=2:6
    ss=ss+1;
    
    names=IndvTable.Properties.VariableNames;
    data(ss,g)=IndvTable.(names{s})(temp);
    
    
    hold on
    
    plot(xx(g)+.1,data(ss,g),'*k')
       
end 
    errorbar(xx(g),meanTable.(groups{g})(temp),std(data(:,g))/sqrt(5),'k')
end 
xticks(xx)
xticklabels(groups)

[h_C,p_C,ci_c,stats_c] = ttest2(data(:,1),data(:,2))
[h_n,p_n,ci_n,stats_n] = ttest2(data(:,3),data(:,4))
if biasremove==1 && ep==1
    title('EMG aftereffects')
    ylabel('|\Delta EMG|')
elseif biasremove==0 && ep==1
    title('Post1_{early}')
     ylabel('||EMG||')
elseif ep==2
     title('Baseline')
     ylabel('||EMG||')
elseif ep==3
    title('Corrective responses')
     ylabel('|\Delta EMG|')
end
set(gcf,'color','w');

% [p,tbl,stats] = anova1(data);
% multcompare(stats)