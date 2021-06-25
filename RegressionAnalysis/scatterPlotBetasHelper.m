function hfig = scatterPlotBetasHelper(coeff, groupIDs, transitionNum, normalized, plotIndex, scatterXRange, scatterYRange, subGroupId, resultDir)
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
    if ~exist('plotIndex', 'var') 
        plotIndex = false; %default false
    end

    hfig = figure('Position', get(0, 'Screensize'));
    hold on;
    colors = {'#0072BD','#D95319','#EDB120','#7E2F8E','#77AC30','#4DBEEE','#A2142F'};

    legendidx = nan(1, 2*length(groupIDs));
    legendLabels = repelem(groupIDs, 2);
    prevK = 0;
    for i = 1:length(groupIDs)
        ind_subj_coeff = coeff{4,i};
        if ~plotIndex
            for k = 1:size(ind_subj_coeff,2)
                plot(ind_subj_coeff{2,k}.Estimate(1), ind_subj_coeff{2,k}.Estimate(2),'.', 'Color',colors{i},'MarkerSize',50); %color based on the group
            end
            plot(coeff{1,i}.Estimate(1), coeff{1,i}.Estimate(2),'o', 'Color',colors{i},'MarkerSize',25,'LineWidth',3); %color based on the group
        else
            for k = 1:size(ind_subj_coeff,2)
                plot(ind_subj_coeff{3,k}(1), ind_subj_coeff{3,k}(2),'.', 'Color',colors{i},'MarkerSize',50); %color based on the group
            end
            plot(coeff{3,i}(1), coeff{3,i}(2),'o', 'Color',colors{i},'MarkerSize',25,'LineWidth',3); %color based on the group
        end

        legendidx(2*i-1) = prevK + k; %previous k 
        legendidx(2*i) = prevK + k + 1;
        legendLabels{2*i} = [legendLabels{2*i} ' Group'];
        prevK = k+1;
    end
    
    f= get(gca,'Children');
    legendidx = length(f) - legendidx +1;
    legend(f(legendidx),legendLabels); 

    if ~plotIndex
        ylabel(['\beta ' coeff{4,i}{2,1}.Row{2}]);
        xlabel(['\beta ' coeff{4,i}{2,1}.Row{1}]);
        title(['Regression Coefficients at Transition ' num2str(transitionNum) ' Normalized ' num2str(normalized)]);
    else
        ylabel(['\beta ' coeff{4,i}{2,1}.Row{2} ' Index']);
        xlabel(['\beta ' coeff{4,i}{2,1}.Row{2} 'Index']);
        title(['Regression Coefficients Index at Transition ' num2str(transitionNum) ' Normalized ' num2str(normalized)]);
    end
    
    if ~exist('scatterXRange', 'var')
        xlim(scatterXRange);
    end

    if ~exist('scatterYRange', 'var')
        ylim(scatterYRange);
    end

    set(gca,'FontSize',22);
    
    if ~exist('resultDir', 'var')  || isempty(resultDir) %no result directory provided, avoid saving
        fprintf('No result directory provided. Figures not auto-saved.\n')
    else 
        if not(isfolder(resultDir))
            mkdir(resultDir)
        end
        resultDir = [resultDir 'scatter_'];
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