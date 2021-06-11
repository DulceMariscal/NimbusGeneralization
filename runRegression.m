function runRegression(Data, normalizeData, isGroupData, dataId, resDir, saveResAndFigure, usefft) 
% perform regression anlysis V2 (see grant one note: Regression discussion (two transitions)
% printout the regression results and save the results to destination
% folders (if saveResAndFigure flag is on)
% ----- Arguments ------
% - Data: a 1x5 cell where each cell contains a 12x28 matrix. The cell
% corresponds to data for: adapt, envSwitch, taskSwitch, transition1 and
% transition 2. The matrix size might differ due to removal of bad data.
% - normalizeData: boolean flag of whether or not to normalize the vector
% (regressor) by the length
% - isGroupData: boolean flag indicating the regression is for individual
% (0) or group results (1)
% - dataId: a string representing the data id (groupID if group data and
% subjectID if individual data), will be used in naming the saved results.
% - saveResAndFigure: a boolean flag to indicate if the results should be
% saved
% - resDir: String, the directory to save the results figures, OPTIONAL if
% saveResAndFigure is false.
% - usefft: OPTIONAL, boolean flag indicating if should use fft of the data to
% approximate deltaOn-, default false.
% 
% ----- Returns ------
%  none
% 
    if nargin < 7 || isempty(usefft)
        usefft = false; %default faulse
    end
    if ~isGroupData
        for i = 1:size(Data,2)
            Data{i} = reshape(Data{i}, [],1); %make it a column vector
        end
    else %group data, take the median
        for i = 1:size(Data,2)
            d = nanmedian(Data{i}, 4);
            Data{i} = reshape(d, [],1); %make it a column vector
        end
    end

    if usefft %do fft - run only once
        Data{size(Data,2) + 1} = Data{1}; %store the current on to the last
        Data{1} = fftshift(Data{1},1);
    end
    
    fprintf('\n\n\n')
    if normalizeData
        for i = 1:size(Data,2)
            Data{i} = Data{i}/norm(Data{i});
        end
    end

    %%% Run regression analysis V2
    tableData=table(Data{1},Data{2},Data{3},Data{4},Data{5},'VariableNames',{'Adapt', 'EnvSwitch', 'TaskSwitch', 'Trans1', 'Trans2'});
    fitTrans1NoConst=fitlm(tableData,'Trans1 ~ TaskSwitch+EnvSwitch+Adapt-1')%exclude constant
    Rsquared = fitTrans1NoConst.Rsquared

    fprintf('\n\n')

    fitTrans2NoConst=fitlm(tableData,'Trans2 ~ TaskSwitch+EnvSwitch+Adapt-1')%exclude constant
    Rsquared = fitTrans2NoConst.Rsquared
    
    %compute and print out relative vector norm to assess the length
    %difference between regressors
    fprintf('\n\n')
    vec_norm = vecnorm(fitTrans1NoConst.Variables{:,:});
    relNom = normalize(vec_norm,'norm',1)
    
    if saveResAndFigure
        if not(isfolder(resDir))
            mkdir(resDir)
        end
        if ~isGroupData
            save([resDir dataId 'models_ver' num2str(usefft) num2str(normalizeData)], 'fitTrans1NoConst','fitTrans2NoConst')
        else
            %version convention: first digit: use first or last stride, 2nd digit:
            %use fft or not, 3rd digit: normalize or not, i.e., ver_101 = use first
            %20 strides, no fft and normalized data
            save([resDir dataId '_group_models_ver' num2str(usefft) num2str(normalizeData)], 'fitTrans1NoConst','fitTrans2NoConst')
        end
    end
end
