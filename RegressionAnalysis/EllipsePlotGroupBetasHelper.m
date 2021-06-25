function hfig = EllipsePlotGroupBetasHelper(coeff, groupIDs, transitionNum, normalized, axisNames, xRange, yRange, resultDir, TRorTS)
% plot coefficieints given in the arguments in bar plots grouped by subject
% group, and error bar indicates group regression fit SE.
% ----- Arguments ------
% - coeff: a cell array of TABLE where each table contains the
% coefficients (in the column Estimates) and SE in the column (SE)
% assuming all coefficients in the tables are in the same order
%
% - groupIDs: a cell array of group IDs used as x labels.
%
% - transitionNum: a INTEGER indicating the transition number (used in titles and
% y axis labels)
%
% - normalized: INTEGER represents if the data is normalized (1) or not (0)
% 
% - axisNames: A cell array of strings to be used as the x and y
% axis names. Pass empty ('') if want to use default name. Default name the row header of the coefficients estimation
% table. 
% 
% - xRange: A row vector of the xaxis range for all figures, in order [lowerAxisLimit, higherAxisLimit]  
%
% - yRange: A row vector of the y-axis range for all figures, in order [lowerAxisLimit, higherAxisLimit]  
% 
% - resultDir: OPTIONAL. the directory to save the results figures, a
% string. If not given or empty, will not save results.
% 
% -TRorTS: OPTIONAL. A string rep of the sub group name, used as prefix of
% the file names to save the results. Default to empty (1 name for the whole 5 groups, no subdivisions)
% 
% ----- Returns ------
%  hfig : the plot handle
% 

    num_coeff = length(coeff{1}.Estimate);
    coeff_combos = nchoosek(1:num_coeff,2);
  
    colors = {'#0072BD','#D95319','#EDB120','#7E2F8E','#77AC30','#4DBEEE','#A2142F'};
    num_groups = length(groupIDs);
    theta = 0 : 0.01 : 2*pi;
    
    if (size(coeff_combos,1) > 1)
        figure;
        hfig = tiledlayout(1,size(coeff_combos,1), 'Padding', 'none', 'TileSpacing', 'compact'); 
    else
        hfig = figure('Position', get(0, 'Screensize'));
    end
    
    for row  = 1:size(coeff_combos,1)
        coeffIdx = coeff_combos(row,:);
        nexttile;
        hold on;
        axis square;
        for j = 1:num_groups
            center = [coeff{1,j}.Estimate(coeffIdx(1)), coeff{1,j}.Estimate(coeffIdx(2))];
            CIRadius_x = abs(diff(coeff{2,j}(coeffIdx(1),:)))/2; %CI of idx1 /2
            CIRadius_y = abs(diff(coeff{2,j}(coeffIdx(2),:)))/2; 

            x = CIRadius_x * cos(theta) + center(1);
            y = CIRadius_y * sin(theta) + center(2);
            plot(x, y, 'LineWidth', 3,'Color',colors{j});
            
        end

        if isempty(axisNames)
            xlabel(['\beta ' coeff{1,1}.Row{coeffIdx(1)}]);
            ylabel(['\beta ' coeff{1,1}.Row{coeffIdx(2)}]);
        else
            xlabel(['\beta ' axisNames{coeffIdx(1)}]);
            ylabel(['\beta ' axisNames{coeffIdx(2)}]);
        end
        set(gca,'FontSize',22);
        set(gca,'XLim',xRange,'YLim',yRange);
    end        
    
    if (size(coeff_combos,1) > 1) 
        sgtitle(['Regression Coefficients 95% CI at Transition ' num2str(transitionNum) ' Normalized ' num2str(normalized)]);
% %        TODO: this looks ugly, font size very small.
    else
        title(['Regression Coefficients 95% CI at Transition ' num2str(transitionNum) ' Normalized ' num2str(normalized)]);
    end
    
    set(gca,'FontSize',22);

    legendLabels = groupIDs;
    legend(legendLabels);

    if ~exist('resultDir', 'var')  || isempty(resultDir) %no result directory provided, avoid saving
        fprintf('No result directory provided. Figures not auto-saved.\n')
    else 
        if not(isfolder(resultDir))
            mkdir(resultDir)
        end
        if ~exist('TRorTS', 'var')
            TRorTS = ''; %default to empty (1 name for the whole 5 groups, no subdivisions)
        end
        saveas(hfig,[resultDir TRorTS 'CI_betas_transition_', num2str(transitionNum), '_normalize_' num2str(normalized) '.png'],'png')
        saveas(hfig,[resultDir TRorTS 'CI_betas_transition_', num2str(transitionNum), '_normalize_' num2str(normalized)],'epsc')
    end
end