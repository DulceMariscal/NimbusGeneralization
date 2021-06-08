function hfig = barplotGroupBetasHelper(coeff, groupIDs, transitionNum, normalized, resultDir)
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
    hfig = figure('Position', get(0, 'Screensize'));
    hold on;
    colors = {'#0072BD','#D95319','#EDB120','#7E2F8E','#77AC30','#4DBEEE','#A2142F'};
    num_coeff = length(coeff{1}.Estimate);
    
    xtickloc = nan(1,length(groupIDs));
    for i = 1:length(groupIDs)
        for j = 1 :num_coeff
            bar(i*(num_coeff+1) + j , coeff{i}.Estimate(j),'FaceColor',colors{j},'EdgeColor',colors{j});%,'.','Color',colors{i},'MarkerSize',40)
            %x, bary, errorlow, errorhigh, the error is absolute value from the bar height   
            errorbar(i*(num_coeff+1) + j,coeff{i}.Estimate(j),coeff{i}.SE(j),coeff{i}.SE(j), 'Color','k','LineWidth',3); 
        end
        xtickloc(i) = i*(num_coeff+1) + j/2 + 0.5;
    end

    set(gca,'XLim',[1*(num_coeff+1) (length(groupIDs)+1)*(num_coeff+1)],'XTick',xtickloc,'XTickLabel',groupIDs);
    set(gca,'FontSize',18);
    ylabel(['\beta at Transition' transitionNum]);
    title(['Regression Coefficients at Transition ' num2str(transitionNum)]);

    f= get(gca,'Children');
    legendLabels = coeff{1}.Row;
    legendLabels{end+1} = 'SE (Group Regression)';
    legendidx = nan(1, num_coeff);
    for i = 1:num_coeff
        legendidx(i) = length(f)-2*(i-1);
    end
    legendidx(num_coeff+1) = length(f) - 1; %SE legend
    legend(f(legendidx),legendLabels); %item plotted 1st, 10th and 20th
    
    if nargin == 5 %no result directory provided, avoid saving
        if not(isfolder(resultDir))
            mkdir(resultDir)
        end
        saveas(hfig,[resultDir 'allgroup_betas_transition_', num2str(transitionNum), '_normalize_' num2str(normalized) '.png'],'png')
    else
        fprintf('No result directory provided. Figures not auto-saved.\n')
    end
end