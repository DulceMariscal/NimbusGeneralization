function refEp = defineReferenceEpoch(userRefEp,ep)
    refEp=ep(strcmp(ep.Properties.ObsNames,userRefEp),:); 
    refEp.Properties.ObsNames{1}=['Ref: ' refEp.Properties.ObsNames{1}];
end