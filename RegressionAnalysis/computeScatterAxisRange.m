function [scatterXRange, scatterYRange] = computeScatterAxisRange(plotIndex)
% Compute the axis ranges for the scatter plots of the regression
% coefficients (or coefficient indexes) estimator of individual and group subjects. 
% Use the axis range for the plots so that transition 1 and 2
% figures for all groups/subgroups and normalized or not normalized will have the save axis range. 
%
% ----- Arguments ------
% - plotIndex: a boolean flag, true if plot coefficient index and false if
% plot the coefficient estimates directly.
%
% ----- Returns ------
% - xRange: a row vector of the xaxis range, [lowerAxisLimit, higherAxisLimit] 
% (to be used for graphs of scatter plots, i.e., both transition 1 and transition 2, 
% for all subgroups, normalized or not normalized)
% 
% - yRange: a row vector of the y-axis range. 


    xRange=[]; yRange = [];
    groups = {'TR_','TS_'};
    for subGroup = groups
        for normalized = 0:1
            [~, ~, coeff_trans1, coeff_trans2, total_subj,~] = loadDataForPlotBetas(normalized, subGroup, '11');
            [xRange1, yRange1] = computeScatterAxisRangeOnePlot(coeff_trans1, total_subj, plotIndex);
            [xRange2, yRange2] = computeScatterAxisRangeOnePlot(coeff_trans2, total_subj, plotIndex);
            xRange = [xRange ; xRange1; xRange2];
            yRange = [yRange ; yRange1; yRange2];
        end
    end
    scatterXRange = [min(xRange(:,1)), max(xRange(:,2))];
    scatterYRange = [min(yRange(:,1)), max(yRange(:,2))];
end