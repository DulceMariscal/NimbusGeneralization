function [data]=getDataEMGtraces(expData,muscle,cond,leg,late,strides)

alignmentLengths=[16,32,16,32];
events={'RHS','LTO','LHS','RTO'};

if leg=='R'
    data=expData.getAlignedField('procEMGData',cond,events,alignmentLengths).getPartialDataAsATS({['R' muscle]});
elseif leg=='L'
    data=expData.getAlignedField('procEMGData',cond,events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle]});
else
    warning('leg input is either L or R')
end

if late==1
    data=data.getPartialStridesAsATS(size(data.Data,3)-strides:size(data.Data,3));
    
elseif late==0
    data=data.getPartialStridesAsATS(1:strides);
else
    error('Input the type of data that you want early=1')
end
    



end
