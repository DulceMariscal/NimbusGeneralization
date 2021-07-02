function [data]=getDataEMGtraces(expData,muscle,cond,leg,late,strides)

alignmentLengths=[16,32,16,32];
events={'RHS','LTO','LHS','RTO'};

if leg=='R'
    data=expData.getAlignedField('procEMGData',cond,events,alignmentLengths).getPartialDataAsATS({['R' muscle]});
elseif leg=='L'
    data=expData.getAlignedField('procEMGData',cond,events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle]});
else
    error('leg input is either L or R')
end

if late==1
    data=data.getPartialStridesAsATS(size(data.Data,3)-strides:size(data.Data,3));
    
elseif late==0
    if size(data.Data,3)>strides
        
        data=data.getPartialStridesAsATS(1:strides);
    else
        data=data.getPartialStridesAsATS(1:size(data.Data,3));
        warning(strcat([cond{1}, ' does not have ', num2str(strides),' strides']))
    end
else
    error('Input the type of data that you want late=1')
end
    



end
