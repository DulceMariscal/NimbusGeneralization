% This script only works after data loading sections from VR_assessIndividualEMGCheckerboard or NIM_assessIndividualEMGCheckerboard
% offer extra comparisons to compare the similarity between off
% perturbation directly to OG vs a linear summation of off perturbation to
% TR + environmental transition from TR to OG
%% Compare Off perturbation to OG vs  off pertubation + multiEnvSwitch
% Compare TRSplitLate - OGPostEarly ~ (TRBase - OGBase) + (TRSplitLate - TRPostEarly)
ep = defineEpochVR_OG_UpdateV3('nanmean', subID);
%         close all;
for i = 1:n_subjects
    adaptDataSubject = normalizedTMFullAbrupt.adaptData{1, i}; 
    
    fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
    ph=tight_subplot(1,3,[.03 .005],.04,.04);
    flip=true;

    Data = {}; 
    %all labels should be the same, no need to save again.
    %  OGPost - TRSplitLate
    [~,~,labels,Data{1},dataRef2]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(15,:),fh,ph(1,1),ep(14,:),flip); 
    title('OGPost - PosSplitLate(fastPrior)')
    % OGBase - TRBase
    [~,~,~,Data{2},~] = adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(1,:),fh,ph(1,2),ep(2,:),flip); %  -(TR base - OG base) = OG base - TR base, env switching
    title('OGBaseLate - TRBaseLate')
    % TRBase - TRSplitEarly
    [~,~,~,Data{3},~]=adaptDataSubject.plotCheckerboards(newLabelPrefix,ep(2,:),fh,ph(1,3),ep(4,:),flip);
    title('TMBaseLate - TMSplitEarly')

    set(ph(:,1),'CLim',[-1 1]);
    set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1.5);
    set(ph,'FontSize',8)
    pos=get(ph(1,end),'Position');
    axes(ph(1,end))
    colorbar
    set(ph(1,end),'Position',pos);
    set(gcf,'color','w');

    resDir = [scriptDir '/RegressionAnalysis/RegModelResults_V14/'];
    if saveResAndFigure
        if not(isfolder(resDir))
            mkdir(resDir)
        end
        saveas(fh, [resDir subID{i} '_TROffLinear' '.png']) 
%             saveas(fh, [resDir subID{i} '_ShoeOffLinear'],'epsc') 
    end

    % run regression and save results
    format compact % format loose %(default)
    YvsTerm1Correlation = corrcoef(Data{1},Data{2})
    YvsTerm2Correlation = corrcoef(Data{1},Data{3})
    corr_coef={YvsTerm1Correlation, YvsTerm2Correlation};
    
    for j = 1:size(Data,2)
        Data{j} = reshape(Data{j}, [],1); %make it a column vector
    end
    YvsTerm1Cos = cosine(Data{1},Data{2})
    YvsTerm2Cos = cosine(Data{1},Data{3})
    cosine_values={YvsTerm1Cos, YvsTerm2Cos};
    
    %%% Run regression to see if the LHS and RHS are equal
    tableData=table(Data{1},Data{2},Data{3},'VariableNames',{'OGToTRSplit', 'OGToTR', 'TRToSplit'});
    linearityAssessmentModel=fitlm(tableData, 'OGToTRSplit~OGToTR+TRToSplit-1')%exclude constant
    Rsquared = linearityAssessmentModel.Rsquared

    if saveResAndFigure
        save([resDir subID{i} '_TROffLinear_CorrCoef_Model'],'corr_coef','cosine_values','linearityAssessmentModel')
    end
end