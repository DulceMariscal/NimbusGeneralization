function hfig = barplotGroupBetasHelper(coeff, groupIDs, transitionNum, normalized, legendLabels, plotIndex, subGroupId, resultDir)
% plot coefficieints given in the arguments in bar plots grouped by subject
% group, and error bar indicates group regression fit SE. Could plot the
% regression coefficients or the coefficients index (see definition from
% the Grant Notebook: Separate regression models to characterize switching within and across environments )
% ----- Arguments ------
% - coeff: a cell array of TABLE where each table contains the
% coefficients (in the column Estimates) and SE in the column (SE)
% assuming all coefficients in the tables are in the same order
%
% - groupIDs: a cell array of group IDs used as x labels.
%
% - transitionNum: an INTEGER indicating the transition number (used in titles and
% y axis labels)
%
% - normalized: INTEGER represents if the data is normalized (1) or not (0)
%
% - legendLabels: OPTIONAL. A cell array containining strings to be used as the
% legend. The lenght of the array should match the number of coefficients.
% Default to the regression coefficients' table's row name.
%
% - plotIndex: OPTIONAL. A boolean flag indiciating if plotting the
% coefficients directly or plotting the coefficient index. Default to
% false.
%
% - subGroupId: OPTIONAL. A string to be used as prefix for file names to
% save the results. Usually TR or TS to indiciating sub groups.
%
% - resultDir: OPTIONAL. the directory to save the results figures, a
% string.
% 
% ----- Returns ------
%  hfig : the plot handle
% 
    if ~exist('plotIndex', 'var') 
        plotIndex = false; %default false
    end

    hfig = figure('Position', get(0, 'Screensize'));
    hold on;
    colors = {'#0072BD','#D95319','#EDB120','#7E2F8E','#77AC30','#4DBEEE','#A2142F'};
    num_coeff = length(coeff{1,1}.Estimate);
    
    xtickloc = nan(1,length(groupIDs));
    for i = 1:length(groupIDs)
        for j = 1 :num_coeff
            if ~plotIndex
                bar(i*(num_coeff+1) + j , coeff{1,i}.Estimate(j),'FaceColor',colors{j},'EdgeColor',colors{j});%,'.','Color',colors{i},'MarkerSize',40)
                %x, bary, errorlow, errorhigh, the error is absolute value from the bar height   
                errorbar(i*(num_coeff+1) + j,coeff{1,i}.Estimate(j),coeff{1,i}.SE(j),coeff{1,i}.SE(j), 'Color','k','LineWidth',3); 
            else
                bar(i*(num_coeff+1) + j , coeff{3,i}(j),'FaceColor',colors{j},'EdgeColor',colors{j});%,'.','Color',colors{i},'MarkerSize',40)
            end
        end
        xtickloc(i) = i*(num_coeff+1) + j/2 + 0.5;
    end

    set(gca,'XLim',[1*(num_coeff+1) (length(groupIDs)+1)*(num_coeff+1)],'XTick',xtickloc,'XTickLabel',groupIDs, 'YLim',[-1.2 1.2]);
    set(gca,'FontSize',18);
    if ~plotIndex
        ylabel(['\beta at Transition' transitionNum]);
    else
        ylabel(['\beta Index at Transition' transitionNum]);
%         ylim([-1,2.0]);
%         ylim([-1.5,2.5]);
        ylim([-1,1]); %after sign correction
    end
    title(['Regression Coefficients at Transition ' num2str(transitionNum) ' Normalized ' num2str(normalized)]);

    f= get(gca,'Children');
       
    legendidx = nan(1, num_coeff);
    if ~plotIndex
        for i = 1:num_coeff
            legendidx(i) = length(f)-2*(i-1);
        end
        if ~exist('legendLabels', 'var') || isempty(legendLabels)
            legendLabels = coeff{1}.Row;
        end
        legendLabels{end+1} = 'SE (Group Regression)';
        legendidx(num_coeff+1) = length(f) - 1; %SE legend
    else
        legendidx = length(f):length(f) - num_coeff+1;
        legendLabels = coeff{1,1}.Row;
        for i = 1:length(legendLabels)
            legendLabels{i} = [legendLabels{i} ' Index'];
        end
    end
    legend(f(legendidx),legendLabels); %item plotted 1st, 10th and 20th
    
    if ~exist('resultDir', 'var')  || isempty(resultDir) %no result directory provided, avoid saving
        fprintf('No result directory provided. Figures not auto-saved.\n')
    else 
        if not(isfolder(resultDir))
            mkdir(resultDir)
        end
        if exist('subGroupId', 'var')
            resultDir = [resultDir,subGroupId];
        end
        
        if plotIndex
            saveName = [resultDir 'beta_index_transition_', num2str(transitionNum), '_normalize_' num2str(normalized)];
        else
            saveName = [resultDir 'betas_transition_', num2str(transitionNum), '_normalize_' num2str(normalized)];
        end
        saveas(hfig,saveName,'png')
        saveas(hfig,saveName,'epsc')
    end
end