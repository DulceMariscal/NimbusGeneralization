function [normalizedTMFullAbrupt, refEp, newLabelPrefix] = getNormalizedDataWithCleanLabels(sub, ep)
    normalizedTMFullAbrupt=adaptationData.createGroupAdaptData(sub);
    
    refEp= defineReferenceEpoch('TMbase',ep);
    muscleOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'GLU', 'HIP'};
    newLabelPrefix = defineMuscleList(muscleOrder);
    normalizedTMFullAbrupt = normalizedTMFullAbrupt.normalizeToBaselineEpoch(newLabelPrefix,refEp); %Normalized by the TM base w VR 
    ll=normalizedTMFullAbrupt.adaptData{1}.data.getLabelsThatMatch('^Norm');
    if (~isempty(ll)) %should not be needed
        warning('Old data naming convention detected')
        l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
        normalizedTMFullAbrupt=normalizedTMFullAbrupt.renameParams(ll,l2);
    end

    newLabelPrefix = regexprep(newLabelPrefix,'_s','s');
end