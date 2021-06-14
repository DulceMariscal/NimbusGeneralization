%% Always run this if needs to load or save data/figures
%get this script's folder, data loading and saving would be based on the current script's location
clear all; close all; clc;
scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 

%% put all regression data into 1 matrix - only need to run it once, the results are saved
coeff_trans1 = {};
coeff_trans2 = {};
subjIDs = {'VROG_03','VROG_02','VrG_Devon','NimbG_BoyanAllMuscles','CVROG_01'};
for i = 1:length(subjIDs)
    load([scriptDir '/RegModelResults/',subjIDs{i},'models.mat'])
    coeff_trans1{i} = fitTrans1NoConst.Coefficients;
    coeff_trans2{i}  = fitTrans2NoConst.Coefficients;
end

%% plot all betas by regressor type/name - preferred
ref_tran1 = [0,-1,1;1 -1 0];
hfig = plotBetasHelper(ref_tran1, coeff_trans1, subjIDs, '1', [scriptDir '/RegModelResults/AllGroupResults/']);
    
ref_tran2 = [1,1,0;0 1 0];
plotBetasHelper(ref_tran2, coeff_trans2, subjIDs, '2', [scriptDir '/RegModelResults/AllGroupResults/']);

%% plot all betas in 3D plots
figure; hold on;
plot3(0,-1,1,'bo','MarkerSize',10,'LineWidth',5);
plot3(1,-1,0,'ko','MarkerSize',10,'LineWidth',5);
for i = 1:length(subjIDs)
    plot3(coeff_trans1{i}.Estimate(1),coeff_trans1{i}.Estimate(2),coeff_trans1{i}.Estimate(3),'.','MarkerSize',40)
end
xlabel('\beta Adapt')
ylabel('\beta EnvSwitch')
zlabel('\beta TaskSwitch')
% xlim([xlim(1),0.16])
subjIDsDisplay = regexprep(subjIDs,'_','');
subjIDsDisplay= ['Good','Bad',subjIDsDisplay];
legend(subjIDsDisplay,'Location','bestoutside');
set(gca,'FontSize',18);
%view -68, -2
view(-68,-2)

%% put all group regression data into 1 matrix - only need to run it once, the results are saved
clear all; close all;% clc;
scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 
coeff_trans1 = {};
coeff_trans2 = {};
normalized = 0;
groupIDs = {'CTR','CTS','VROG','NTR','NTS'};
for i = 1:length(groupIDs)
    load([scriptDir '/RegModelResults_V6/GroupResults/',groupIDs{i},'_group_models_ver0' num2str(normalized) '.mat'])
    coeff_trans1{i} = fitTrans1NoConst.Coefficients;
    coeff_trans2{i}  = fitTrans2NoConst.Coefficients;
end
%% plot bar plot of the group regression data
legendLabels = {'Adapt','Within Context Switch','Multi Context Switch'};
barplotGroupBetasHelper(coeff_trans1, groupIDs, 1, normalized, legendLabels, [scriptDir '/RegModelResults_V6/AllGroupResults/'])
barplotGroupBetasHelper(coeff_trans2, groupIDs, 2, normalized, legendLabels, [scriptDir '/RegModelResults_V6/AllGroupResults/'])
% task switch ~= no-adapt, env+task switch = switching

%% plot 2D ellipses of group beta with CI
clear all; close all; clc;
scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 
coeff_trans1 = {};
coeff_trans2 = {};
normalized = 0;
groupIDs = {'CTR','CTS','VROG','NTR','NTS'};
for i = 1:length(groupIDs)
    load([scriptDir '/RegModelResults_V7/GroupResults/',groupIDs{i},'_group_models_ver0' num2str(normalized) '.mat'])
    coeff_trans1{1,i} = fitTrans1NoConst.Coefficients;
    coeff_trans1{2,i} = fitTrans1NoConst.coefCI;
    coeff_trans2{1,i}  = fitTrans2NoConst.Coefficients;
    coeff_trans2{2,i} = fitTrans2NoConst.coefCI;
end

%% plot bar plot of the group regression data
legendLabels = {'Adapt','Within Context Switch','Multi Context Switch'};
resultDir = [scriptDir '/RegModelResults_V7/AllGroupResults/'];
barplotGroupBetasHelper(coeff_trans1, groupIDs, 1, normalized, legendLabels, resultDir)
barplotGroupBetasHelper(coeff_trans2, groupIDs, 2, normalized, legendLabels, resultDir)
% task switch ~= no-adapt, env+task switch = switching

%% plot 2D ellipses
axisLabels = {'Adapt','Within Context Switch','Multi Context Switch'};
fig1 = EllipsePlotGroupBetasHelper(coeff_trans1, groupIDs, 1, normalized, axisLabels, resultDir)
fig2 = EllipsePlotGroupBetasHelper(coeff_trans2, groupIDs, 2, normalized, axisLabels, resultDir)

%% save results after manually making the figure full screen.
savename1 = [resultDir 'CI_betas_transition_1_normalize_' num2str(normalized)];
savename2 = [resultDir 'CI_betas_transition_2_normalize_' num2str(normalized)];
saveas(fig1, savename1,'png')
saveas(fig1, savename1,'fig')
saveas(fig1, savename1,'epsc')
saveas(fig2, savename2,'png')
saveas(fig2, savename2,'fig')
saveas(fig2, savename2,'epsc')
