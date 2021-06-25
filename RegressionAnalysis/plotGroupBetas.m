%% Define empty range
% [indexScatterXRange, indexScatterYRange] = computeScatterAxisRange(true);
% [betaScatterXRange, betaScatterYRange] = computeScatterAxisRange(false);
%% plot 2D ellipses of group beta with CI
% clear all; close all; clc;
normalized = 0
subGroup = 'TS_'
[scriptDir, groupIDs, coeff_trans1, coeff_trans2, total_subj,resultDir] = loadDataForPlotBetas(normalized, subGroup, '11');
%% plot bar plot of the group regression data
legendLabels = {'Adapt','Within Context Switch','Multi Context Switch'};
barplotGroupBetasHelper(coeff_trans1, groupIDs, 1, normalized, legendLabels)
barplotGroupBetasHelper(coeff_trans2, groupIDs, 2, normalized, legendLabels)
% task switch ~= no-adapt, env+task switch = switching

%% plot 2D ellipses
% axisLabels = {'Adapt','Within Context Switch','Multi Context Switch'};
[xRange, yRange] = compute2DEllipseAxisRange(coeff_trans1, coeff_trans2);
fig1 = EllipsePlotGroupBetasHelper(coeff_trans1, groupIDs, 1, normalized, '', xRange, yRange, '', subGroup);
fig2 = EllipsePlotGroupBetasHelper(coeff_trans2, groupIDs, 2, normalized, '', xRange, yRange, '', subGroup);

% fig1 = EllipsePlotGroupBetasHelper(coeff_trans1, groupIDs, 1, normalized, axisLabels, xRange, yRange);
% fig2 = EllipsePlotGroupBetasHelper(coeff_trans2, groupIDs, 2, normalized, axisLabels, xRange, yRange);

%% save results after manually making the figure full screen.
savename1 = [resultDir 'CI_betas_transition_1_normalize_' num2str(normalized)];
savename2 = [resultDir 'CI_betas_transition_2_normalize_' num2str(normalized)];
saveas(fig1, savename1,'png')
saveas(fig1, savename1,'fig')
saveas(fig1, savename1,'epsc')
saveas(fig2, savename2,'png')
saveas(fig2, savename2,'fig')
saveas(fig2, savename2,'epsc')

%% plot indexes of the beta
barplotGroupBetasHelper(coeff_trans1, groupIDs, 1, normalized, '',true, subGroup)
barplotGroupBetasHelper(coeff_trans2, groupIDs, 2, normalized, '',true, subGroup, '')
% (coeff, groupIDs, transitionNum, normalized, legendLabels, plotIndex, subGroupId, resultDir)

%% plot the scatter plots of betas
% scatterPlotBetasHelper(coeff, groupIDs, transitionNum, normalized, plotIndex, scatterXRange, scatterYRange, subGroupId, resultDir)
close all;
[betaScatterXRange, betaScatterYRange] = computeScatterAxisRange(false);
scatterPlotBetasHelper(coeff_trans1, groupIDs, 1, normalized, false, betaScatterXRange, betaScatterYRange, subGroup, '');
scatterPlotBetasHelper(coeff_trans2, groupIDs, 2, normalized, false, betaScatterXRange, betaScatterYRange, subGroup, '');

%% plot the scatter plots of betas index
close all;
[indexScatterXRange, indexScatterYRange] = computeScatterAxisRange(true);
scatterPlotBetasHelper(coeff_trans1, groupIDs, 1, normalized, true, indexScatterXRange, indexScatterYRange, subGroup, '');
scatterPlotBetasHelper(coeff_trans2, groupIDs, 2, normalized, true, indexScatterXRange, indexScatterYRange, subGroup, '');