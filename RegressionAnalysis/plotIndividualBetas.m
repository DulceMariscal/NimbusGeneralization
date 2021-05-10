%% put all regression data into 1 matrix
coeff_trans1 = {};
coeff_trans2 = {};
subjIDs = {'VROG_03','VROG_02','VrG_Devon','NimbG_BoyanAllMuscles','CVROG_01'};
for i = 1:length(subjIDs)
    load(['/Users/mac/Desktop/Lab/SMLLab/Code/R01_MyFork/RegModelResults/',subjIDs{i},'models.mat'])
    coeff_trans1{i} = fitTrans1NoConst.Coefficients;
    coeff_trans2{i}  = fitTrans2NoConst.Coefficients;
end

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

%% plot all betas by regressor type/name
ref_tran1 = [0,-1,1;1 -1 0];
hfig = plotBetasHelper(ref_tran1, coeff_trans1, subjIDs, '1');

ref_tran2 = [1,1,0;0 1 0];
plotBetasHelper(ref_tran2, coeff_trans2, subjIDs, '2');