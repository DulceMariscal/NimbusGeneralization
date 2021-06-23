function [xRange, yRange] = computeScatterAxisRangeOnePlot(coeff, total_n_subjects, plotIndex)
% Compute the axis ranges for the scatter plots of the regression
% coefficients (or coefficient indexes) estimator of individual and group
% subjects, for 1 figure (1 subgroup and 1 transition, e.g., TR_trans1).
% Likely used as a helper function for computerScatterAxisRange
%
% ----- Arguments ------
% - coeff: a 4xn (n= # of groups) cell array containing the regression coefficients
% of relevant groups for a transition. Row 1 of the cell array is the table of the regression coefficient estimates.
% Row 2 of the cell array is a matrix representing the
% confidence interval of each regressor (row: regression, columns: CIlow,
% CIhigh. 
%
% - total_n_subjects: An integer representing the total number of subjects
% across all the groups. e.g., if the given coefficients are for TR subgroup that includes NTR and CTR,
% the total_n_subjects = #subjects in NTR + #subjects in CTR.
% 
% - plotIndex: OPTIONAL. a boolean flag, true if plot coefficient index and false if
% plot the coefficient estimates directly. Default false.
%
% ----- Returns ------
% - xRange: a row vector of the xaxis range, [lowerAxisLimit, higherAxisLimit] 
% (to be used for 1 graph of scatter plots, i.e., for transition 1, TR
% subgroup, normalized)
% 
% - yRange: a row vector of the y-axis range. 

    num_group = size(coeff, 2);
     
    if ~exist('plotIndex', 'var') 
        plotIndex = false; %default false
    end
    
    xs= nan(1,total_n_subjects);
    ys = nan(1,total_n_subjects);
    idx = 0;
    for i = 1:num_group
        ind_subj_coeff = coeff{4,i};
        if ~plotIndex
            for k = 1:size(ind_subj_coeff,2)
                idx = idx + 1;
                xs(idx) = ind_subj_coeff{2,k}.Estimate(1);
                ys(idx) = ind_subj_coeff{2,k}.Estimate(2);
                
            end
            xs(idx) = coeff{1,i}.Estimate(1);
            ys(idx) = coeff{1,i}.Estimate(2);
        else
            for k = 1:size(ind_subj_coeff,2)
                idx = idx + 1;
                xs(idx) = ind_subj_coeff{3,k}(1);
                ys(idx) = ind_subj_coeff{3,k}(2);
            end
            xs(idx) = coeff{3,i}(1);
            ys(idx) = coeff{3,i}(2);
        end
    end    
    
    xRange = [min(xs)-0.025, max(xs)+0.025]; %+-0.025 buffer
    yRange = [min(ys)-0.025, max(ys)+0.025]; %+-0.025 buffer
    
end