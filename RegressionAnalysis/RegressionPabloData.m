%% using my data
tableData=table(nanmedian(data{1,1}.deltaObs_Reshaped,2), -nanmedian(data{1,1}.onPlus_Reshaped,2),...
    nanmedian(data{1,1}.onMinus_Reshaped, 2),nanmedian(data{1,1}.lateAda,2), 'VariableNames',{'ePlA','eA','eAT','lA'});

fit = fitlm(tableData,'ePlA ~ eA + lA + eAT -1')
controlDataTemp = [nanmedian(data{1,1}.deltaObs_Reshaped,2), -nanmedian(data{1,1}.onPlus_Reshaped,2),...
    nanmedian(data{1,1}.onMinus_Reshaped, 2),nanmedian(data{1,1}.lateAda,2)]

%% using dulce's data
% shortNames{'lB','eA','lA','lS','eP','ePS','veA','veP','veS','vePS','lP','e15A','e15P'};
% longNames={'Base','early A','late A','Short','early P','early B','vEarly A','vEarly P','vShort','vEarly B','late P','early A15','early P15'};
% v = very early

%get this script's folder, data loading and saving would be based on the current script's location
scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 
cd(scriptDir);
load('../data/pablosData/OldAdultsData_WO_ADMEMGsummary.mat')

eAT = fftshift(eA,1); 
tableData = table(nanmedian(eP,2)-nanmedian(lA,2), -nanmedian(eA,2), nanmedian(eP,2), nanmedian(lA,2),nanmedian(eAT,2),...
        'VariableNames',{'eP_lA','eA','eP','lA','eAT'});
fit = fitlm(tableData,'eP_lA ~ eA + eAT -1')    
% writetable(tableData, 'groupRegData.csv') %for python

%% fit the new model
%deltaEMGminuts, emgbase - emgSS
% Long Exposure
tableData = table(nanmedian(eP,2)-nanmedian(lA,2), nanmedian(eAT,2),nanmedian(lB , 2)-nanmedian(lA , 2),...
        'VariableNames',{'Trans1','Adapt','TaskSwitch'}); %ep-la ~ deltaEMG- + (EMGBase - EMGSS)
    %(EMGBase - EMGSS) = - EMGSS since SS by default is corrected by the
    %baseline, lB is an all zero matrix
fit_long = fitlm(tableData,'Trans1 ~ Adapt + TaskSwitch -1') 
fit_long.Rsquared

% Short Exposure
%FIXME: might need to reprocess the data to get correct eA for short
%exposure
tableData = table(nanmedian(ePS,2)-nanmedian(lS,2), nanmedian(eAT,2),-nanmedian(lS , 2),...
    'VariableNames',{'Trans1','Adapt','TaskSwitch'}); %ep-la ~ deltaEMG- + (EMGBase - EMGSS)
%(EMGBase - EMGSS) = - EMGSS since SS by default is corrected by the
%baseline
fit_short = fitlm(tableData,'Trans1 ~ Adapt + TaskSwitch -1') 
fit_short.Rsquared
% ttS=table(-median(eA(muscleIdx,subjIdx),2), median(eAT(muscleIdx,subjIdx),2), 
% -median(lS(muscleIdx,subjIdx),2), median(ePS(muscleIdx,subjIdx),2)-median(lS(muscleIdx,subjIdx),2),
% 'VariableNames',{'eA','eAT','lS','ePS_lS'});
% fitlm(ttS,'ePS_lS~lS+eAT-1','RobustOpts',rob)
% ttSb
fit_ind_short = {1,16};
fit_ind_long={1,16};
for i = 1:16
    tableData = table(eP(:,i) - lA(:,i), eAT(:,i), -lA(:,i),...
    'VariableNames',{'Trans1','Adapt','TaskSwitch'}); %ep-la ~ deltaEMG- + (EMGBase - EMGSS)
    %(EMGBase - EMGSS) = - EMGSS since SS by default is corrected by the baseline
    fit_ind_long{i} = fitlm(tableData,'Trans1 ~ Adapt + TaskSwitch -1'); 
    
    tableData = table(ePS(:,i)-lS(:,i), eAT(:,i),-lS(:,i),...
    'VariableNames',{'Trans1','Adapt','TaskSwitch'}); %ep-la ~ deltaEMG- + (EMGBase - EMGSS)
    fit_ind_short{i} = fitlm(tableData,'Trans1 ~ Adapt + TaskSwitch -1');
end


%% plotting
fh = figure('Position', get(0, 'Screensize'));
figuresColorMap;
figuresColorMap %load colors. 1-gray, 2-green, 3-purple, 4-orange ish
condColors(4,:) = [0.9290, 0.6940, 0.1250]; %orangeish

rL=fit_long.Coefficients.Estimate;
rS=fit_short.Coefficients.Estimate;
hold on
scatter(rS(2),rS(1),210,condColors(1,:),'filled')
text(rS(2)+0.01,rS(1)+.01,{'Group','Median'},'Color',condColors(1,:)/2,'FontWeight','bold','FontSize',15);  
scatter(rL(2),rL(1),210,'k','filled')
text(rL(2)+.02,rL(1),{'Group','Median'},'Color','k','FontWeight','bold','FontSize',15); 

xlabel(['\color[rgb]{' num2str(condColors(4,1)) ',' num2str(condColors(4,2)) ',' num2str(condColors(4,3)) '} \beta_{TaskSwitch}'])
ylabel(['\color[rgb]{' num2str(condColors(3,1)) ',' num2str(condColors(3,2)) ',' num2str(condColors(3,3)) '} \beta_{Adapt}'])

for i = 1:16
    scatter(fit_ind_short{i}.Coefficients.Estimate(2),fit_ind_short{i}.Coefficients.Estimate(1),120,condColors(1,:),'filled','MarkerFaceAlpha',.7); %short exposure    
%     scatter(fit_ind_long{i}.Coefficients.Estimate(2),fit_ind_long{i}.Coefficients.Estimate(1),60,condColors(2,:),'filled','MarkerFaceAlpha',.7); %long exposure    
    scatter(fit_ind_long{i}.Coefficients.Estimate(2),fit_ind_long{i}.Coefficients.Estimate(1),120,'k','filled','MarkerFaceAlpha',.9); %long exposure    
end
scatter(0,1,210,condColors(3,:),'filled'); 
text(0.01,1,{'New','Normal'},'Color',condColors(3,:),'FontWeight','bold','FontSize',15); 
scatter(1,0,210,condColors(4,:),'filled'); 
text(1.01,0,{'No','Adaptation'},'Color',condColors(4,:),'FontWeight','bold','FontSize',15); 
f= get(gca,'Children');
legend(f([end,end-2]),{'Short Exposure','Long Exposure'})

ax=gca;
ax.XLabel.FontWeight='bold';
ax.XColor=condColors(4,:);
ax.YColor=condColors(3,:);
ax.XAxis.LineWidth=2;
ax.YAxis.LineWidth=2;
ax.YLabel.FontWeight='bold';
set(gca,'FontSize',18);

% axis([-.7 1.55 -.5 1.5]) 
title('Regression analysis of Old Data: Trans1 ~ Adapt + TaskSwitch -1')
saveas(fh, [scriptDir '/RegModelResults/AllSubjectsOrGroupResults/pabloData_newModelBetas_defaultAxis.png'])

%% correlation matrix plot - not in use, handled in python
vars = [tableData.('eP_lA'),tableData.('eA'),tableData.('eAT'),tableData.('lA')];
varCorr = corrcoef(vars);
imagesc(varCorr); % plot the matrix
set(gca, 'XTick', 1:size(varCorr,1)); % center x-axis ticks on bins
set(gca, 'YTick', 1:size(varCorr,2)); % center y-axis ticks on bins
set(gca, 'XTickLabel', {'eP-lA','eA','eAT','lA'}); % set x-axis labels
set(gca, 'YTickLabel', {'eP-lA','eA','eAT','lA'}); % set y-axis labels
title('Your Title Here', 'FontSize', 14); % set title
colormap('jet'); % set the colorscheme
colorbar; % enable colorbar

