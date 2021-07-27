function runRegression_V3(Data, normalizeData, isGroupData, dataId, resDir, saveResAndFigure, version, usefft, regressorNames) 
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
% - version: OPTIONAL, string (case insensitive)), representing which regression version to use, allowed strings: 'default' =
% with 3 regressors (see Alterntive Regression page on grant notebook), 'tr' =
% 2 regressors version for training group, 'ts' = 2 regressors version for
% testing group (see Separate regression models to characterize switching within and across environments from Grant Notebook)
% - usefft: OPTIONAL, boolean flag indicating if should use fft of the data to
% approximate deltaOn-, default false.
% - regressorNames: OPTIONAL, a cell array of the regressor names, size of
% 1 x 5, default name: {'Adapt','WithinContextSwitch','MultiContextSwitch','Trans1','Trans2'}
% 
% ----- Returns ------
%  none
% 
    if nargin < 7 || isempty(version)
        version = 'default'; %default 1
    end
    if nargin < 8 || isempty(usefft)
        usefft = false; %default false
    end
    if nargin < 9
        regressorNames = {'Adapt','WithinContextSwitch','MultiContextSwitch','Trans1','Trans2'}; %default names
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
    normalizeData
    if normalizeData
        for i = 1:size(Data,2)
            Data{i} = Data{i}/norm(Data{i});
        end
    end

    %define model based on the version, version has to fall in 1 of the 3
    %categories, otherwise there is a bug in the code.
    if strcmpi(version,'default') %default, 3 regressors version
        trans1Model = [regressorNames{4} '~' regressorNames{1} '+' regressorNames{2} '+' regressorNames{3} '-1'];
        trans2Model = [regressorNames{5} '~' regressorNames{1} '+' regressorNames{2} '+' regressorNames{3} '-1'];
    elseif strcmpi(version,'tr') %training group
        trans1Model = [regressorNames{4} '~' regressorNames{1} '+' regressorNames{2} '-1'];
        trans2Model = [regressorNames{5} '~' regressorNames{1} '+' regressorNames{3} '-1'];
    elseif strcmpi(version,'ts') %testing group
        trans1Model = [regressorNames{4} '~' regressorNames{1} '+' regressorNames{3} '-1'];
        trans2Model = [regressorNames{5} '~' regressorNames{1} '+' regressorNames{3} '-1'];
    end
    
    %%% Run regression analysis V2
    tableData=table(Data{1},Data{2},Data{3},Data{4},Data{5},'VariableNames',regressorNames);
    fitTrans1NoConst=fitlm(tableData,trans1Model)%exclude constant
    Rsquared = fitTrans1NoConst.Rsquared
    %compute adaptation and switch index
    beta1_index = computeBetaIndex(fitTrans1NoConst);
    
    fprintf('\n\n')

    fitTrans2NoConst=fitlm(tableData,trans2Model)%exclude constant
    Rsquared = fitTrans2NoConst.Rsquared
    %compute adaptation and switch index
    beta2_index = computeBetaIndex(fitTrans2NoConst);

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
            save([resDir dataId 'models_ver' num2str(usefft) num2str(normalizeData)], 'fitTrans1NoConst','fitTrans2NoConst','beta1_index','beta2_index','relNom');
        else
            %version convention: first digit: use first or last stride, 2nd digit:
            %use fft or not, 3rd digit: normalize or not, i.e., ver_101 = use first
            %20 strides, no fft and normalized data
            save([resDir dataId '_group_models_ver' num2str(usefft) num2str(normalizeData)], 'fitTrans1NoConst','fitTrans2NoConst','beta1_index','beta2_index','relNom');
        end
    end
end
