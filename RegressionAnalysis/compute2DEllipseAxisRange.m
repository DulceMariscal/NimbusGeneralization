function [xRange, yRange] = compute2DEllipseAxisRange(coeff_trans1, coeff_trans2) 
% Compute the axis ranges for the 2D ellipses plots of the CI of
% coefficients based on the range of data. Use the axis range for the plots so that transition 1 and 2
% figures will have the save axis range. 
%
% ----- Arguments ------
% - coeff_trans1: a 4xn (n= # of groups) cell array containing the regression coefficients
% of relevant groups for transition 1. Row 1 of the cell array is the table of the regression coefficient estimates.
% Row 2 of the cell array is a matrix representing the
% confidence interval of each regressor (row: regression, columns: CIlow,
% CIhigh. 
%
% - coeff_trans2: cell array for transition 2. Similar structure as
% coeff_trans1. 
%
% ----- Returns ------
% - xRange: a row vector of the xaxis range, [lowerAxisLimit, higherAxisLimit] (to be used for graphs of both
% transition 1 and transition 2)
% 
% - yRange: a row vector of the y-axis range. 

%TODO: potentially make the axis range the same for normalized vs
%not-normalized data too.

    num_group = size(coeff_trans1, 2);
    
    xRange = [inf, -inf];
    yRange = [inf, -inf];
    
    for i = 1:num_group
        num_coeff = length(coeff_trans1{1,i}.Estimate);
        coeff_combos = nchoosek(1:num_coeff,2);    
        CI1 = coeff_trans1{2,i};
        CI2 = coeff_trans2{2,i};
        
        range = [CI1(coeff_combos(:,1),:);CI2(coeff_combos(:,1),:)];
        minRange = min(range);
        maxRange = max(range);
        if (minRange(1) < xRange(1))
            xRange(1) = minRange(1);
        end
        if maxRange(2) > xRange(2)
            xRange(2) = maxRange(2);
        end
       
        range = [CI1(coeff_combos(:,2),:);CI2(coeff_combos(:,2),:)];
        minRange = min(range);
        maxRange = max(range);
        if (minRange(1) < yRange(1))
            yRange(1) = minRange(1);
        end
        if maxRange(2) > yRange(2)
            yRange(2) = maxRange(2);
        end
    end
    
    xRange = [xRange(1)-0.025, xRange(2)+0.025]; %+-0.025 buffer
    yRange = [yRange(1)-0.025, yRange(2)+0.025]; %+-0.025 buffer
    
end