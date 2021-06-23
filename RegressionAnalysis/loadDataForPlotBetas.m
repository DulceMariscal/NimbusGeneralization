function [scriptDir, groupIDs, coeff_trans1, coeff_trans2, total_subj,resultDir] = loadDataForPlotBetas(normalized, subGroup, verNumString)
% Load the data and set up (return) the variables to plot group betas (
% 
% 
% 
%
% 
% 
% 
% 
% 

    scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 

    if strcmp(subGroup, 'TR_')
        groupIDs = {'CTR','NTR'};
    elseif strcmp(subGroup, 'TS_')
        groupIDs = {'NTS','CTS'};
    elseif strcmp(subGroup, 'TSVR_')
        groupIDs = {'NTS','CTS','VROG'};
    else %default, is empty use all
        groupIDs = {'CTR','CTS','VROG','NTR','NTS'};
    end
    
    coeff_trans1 = cell(4,length(groupIDs));
    coeff_trans2 = cell(4,length(groupIDs));
    total_subj = 0;
    
    for i = 1:length(groupIDs)
        load([scriptDir '/RegModelResults_V' verNumString '/GroupResults/',groupIDs{i},'_group_models_ver0' num2str(normalized) '.mat'])
        coeff_trans1{1,i} = fitTrans1NoConst.Coefficients;
        coeff_trans1{2,i} = fitTrans1NoConst.coefCI;
        coeff_trans1{3,i} = beta1_index;
        coeff_trans2{1,i}  = fitTrans2NoConst.Coefficients;
        coeff_trans2{2,i} = fitTrans2NoConst.coefCI;
        coeff_trans2{3,i} = beta2_index;
        files = dir ([scriptDir '/RegModelResults_V' verNumString '/' groupIDs{i} '*models_ver0' num2str(normalized) '.mat']);
        n_subjects = size(files,1);
        coeff_trans1{4,i} = cell(3,n_subjects); %row1: subjFileName, row2:coefficients, row3: beta_index
        coeff_trans2{4,i} = cell(3,n_subjects);
        for j = 1:n_subjects
            load([files(j).folder '/' files(j).name]); %TODO: this can be redesigned for a class structure
            coeff_trans1{4,i}{1,j} = files(j).name;
            coeff_trans1{4,i}{2,j} = fitTrans1NoConst.Coefficients;
            coeff_trans1{4,i}{3,j} = beta1_index;
            coeff_trans1{4,i}{1,j} = files(j).name;
            coeff_trans2{4,i}{2,j} = fitTrans2NoConst.Coefficients;
            coeff_trans2{4,i}{3,j} = beta2_index;
        end
        total_subj = total_subj + n_subjects;
    end
    
    resultDir = [scriptDir '/RegModelResults_V' verNumString '/AllGroupResults/'];
end