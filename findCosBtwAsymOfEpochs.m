function [cosAsym, cosAsymNormalized] = findCosBtwAsymOfEpochs(Data, numLabels, variableNames)
% find cosine between the asymmetry between 2 legs of each regressors and transition1 and transition 2.
    if nargin < 3
        variableNames = {'Adapt','WithinContextSwitch','MultiContextSwitch','Trans1','Trans2'}; %default names
    end    
    asymData = Data;
    cosAsym = nan(2,3);
    %top half is the asymmetry data
    asym_trans1 = asymData{4}(:,1:numLabels/2);
    asym_trans1 = reshape(asym_trans1, [],1); %make it a column vector
    asym_trans2 = asymData{5}(:,1:numLabels/2);
    asym_trans2 = reshape(asym_trans2, [],1); %make it a column vector
    colName = cell(1,3);
    for i = 1:3
        currAsym = reshape(asymData{i}(:,1:numLabels/2), [],1);
        cosAsym (1,i) = cosine(currAsym, asym_trans1);
        cosAsym (2,i) = cosine(currAsym, asym_trans2);
        colName{i} = ['CosWith' variableNames{i}];
    end
    
    cosAsym = array2table(cosAsym);
    cosAsym.Properties.VariableNames = colName;
    cosAsym.Properties.RowNames = variableNames(:,4:5);
end