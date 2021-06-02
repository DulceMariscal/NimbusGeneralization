function hfig = plotBetasHelper(ref_betas, coeff, subjIDs, transitionNum, resultDir)
% plot coefficieints givein in the arguments
% ----- Arguments ------
% - ref_betas: the reference betas for good and bad adaptors, 2D array in 2 x
% numCoefficients. 
% - coeff: a cell array of tables where each table contains the coefficients, in the column Estimates
% assuming all coefficients in the tables are in the same order
% - subjIDs: a cell array of subject IDs used as legends.
% - transitionNum: a string rep of the transition number (used in titles and
% y axis labels)
% - resultDir: the directory to save the results figures
% 
% ----- Returns ------
%  hfig : the plot handle
% 
    hfig = figure('Position', get(0, 'Screensize'));
    hold on;
    colors = {'#0072BD','#D95319','#EDB120','#7E2F8E','#77AC30','#4DBEEE','#A2142F'};
    ref_colors = ['b','k'];
    num_coeff = length(coeff{1}.Estimate);
    for i = 1:2
        for j = 1:num_coeff
            plot(j,ref_betas(i,j),[ref_colors(i) 'o'],'MarkerSize',20,'LineWidth',5);
        end
    end

    for i = 1:length(subjIDs)
        for j = 1 :num_coeff
            plot(j, coeff{i}.Estimate(j),'.','Color',colors{i},'MarkerSize',40)
        end
    end
    set(gca,'XLim',[0 4],'XTick',[1,2,3],'XTickLabel',coeff{1}.Properties.RowNames)
    subjIDsDisplay = regexprep(subjIDs,'_','');
    subjIDsDisplay= ['Good','Bad',subjIDsDisplay];
    f= get(gca,'Children');
    legendIdx = 3* [1:length(subjIDsDisplay)];
    legend(f(end +1  - legendIdx),subjIDsDisplay); %first plotted item is at the last
    set(gca,'FontSize',18);
    ylabel(['\beta at Transition' transitionNum]);
    title(['Regression Coefficients at Transition ' transitionNum]);
    if not(isfolder(resultDir))
        mkdir(resultDir)
    end
    saveas(hfig,[resultDir 'betas_transition_', transitionNum, '.png'],'png')
end