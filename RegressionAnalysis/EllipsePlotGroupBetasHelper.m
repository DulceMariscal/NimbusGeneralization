function hfig = EllipsePlotGroupBetasHelper(coeff, groupIDs, transitionNum, normalized, axisNames, resultDir)
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
% - resultDir: OPTIONAL. the directory to save the results figures, a
% string
% 
% ----- Returns ------
%  hfig : the plot handle
% 

    num_coeff = length(coeff{1}.Estimate);
    coeff_combos = nchoosek(1:num_coeff,2);


%     EllipsePlotGroupBetasHelper(coeff_trans1, groupIDs, coeff_combos(row,:), 1, normalized, axisLabels, resultDir);
%     EllipsePlotGroupBetasHelper(coeff_trans2, groupIDs, coeff_combos(row,:), 2, normalized,axisLabels, resultDir);

    
    
    colors = {'#0072BD','#D95319','#EDB120','#7E2F8E','#77AC30','#4DBEEE','#A2142F'};
    num_groups = length(groupIDs);
    theta = 0 : 0.01 : 2*pi;
    figure;
    hfig = tiledlayout(1,3, 'Padding', 'none', 'TileSpacing', 'compact'); 
%     hfig = subplot('Position', get(0, 'Screensize'));
    for row  = 1:size(coeff_combos,1)
        coeffIdx = coeff_combos(row,:);
%         subplot(1,3,row); %,'Position', get(0, 'Screensize')
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
        if normalized
            set(gca,'XLim',[-0.3,1],'YLim',[-1,1]);
        else
            set(gca,'XLim',[-0.2,0.6],'YLim',[-1.5,1.5]);
        end
        
        set(gca,'FontSize',22);
    end
    
    sgtitle(['Regression Coefficients 95% CI at Transition ' num2str(transitionNum)]);
    set(gca,'FontSize',22);

    legendLabels = groupIDs;
    legend(legendLabels);

    if nargin < 6 || isempty(resultDir) %no result directory provided, avoid saving
        fprintf('No result directory provided. Figures not auto-saved.\n')
        [resultDir 'CI_betas_',num2str(coeffIdx),'_transition_', num2str(transitionNum), '_normalize_' num2str(normalized) '.png']
        
    else 
        if not(isfolder(resultDir))
            mkdir(resultDir)
        end
        saveas(hfig,[resultDir 'CI_betas_',num2str(coeffIdx),'_transition_', num2str(transitionNum), '_normalize_' num2str(normalized) '.png'],'png')
        saveas(hfig,[resultDir 'CI_betas_',num2str(coeffIdx),'_transition_', num2str(transitionNum), '_normalize_' num2str(normalized)],'epsc')
    end
end