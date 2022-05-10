clc

groups={'CTR','CTS','NTR','NTS'};
% groups={'CTR','CTS'};
biasremove=1;

Epoch={'Post1_{Early}','Ref:','Post1-Adapt_{SS}'};
ep=3;
figure


for g=1:4
    xx=[1 2 5 6];
    
    load(['Norm_', groups{g},'_',num2str(biasremove)])
    ss=0;
    temp=contains(IndvTable.Epoch,Epoch{ep});
    bar(xx(g), IndvTable.TestAvg(temp))
    if contains('NTS',groups{g})
        sub=2:4;
    else
        sub=2:6;
    end
for s=sub
    ss=ss+1;
    
    names=IndvTable.Properties.VariableNames;
    data(ss,g)=IndvTable.(names{s})(temp);
    
    
    hold on
    
    plot(xx(g)+.1,data(ss,g),'*k')
       
end 
    errorbar(xx(g),IndvTable.TestAvg(temp),std(data(:,g))/sqrt(5),'k')
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


%% Power Analysis 
clc
%controls - Early Post 1 
control=1
Epoch={'Post1_{Early}'};
if control==1
load('Norm_CTR_1')
else
load('Norm_NTR_1')   
end
temp=contains(IndvTable.Epoch,Epoch);
TR_GroupAvg=IndvTable.TestAvg(temp);
TR_GroupSD=IndvTable.SD(temp);

if control==1
load('Norm_CTS_1')
else
load('Norm_NTS_1')   
end

temp=contains(IndvTable.Epoch,Epoch);
TS_GroupAvg=IndvTable.TestAvg(temp);
TS_GroupSD=IndvTable.SD(temp);

if control==1
disp(['Power Analysis with Controls for ' Epoch{1}])
else
disp(['Power Analysis with Nimbus for ' Epoch{1}])    
end
n = sampsizepwr('t2',[TR_GroupAvg TR_GroupSD],[TS_GroupAvg],0.80)