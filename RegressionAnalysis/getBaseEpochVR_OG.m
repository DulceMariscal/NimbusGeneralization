function baseEp=getBaseEpochVR_OG()
ep=defineEpocVR_OG('nanmean');
baseEp=ep(strcmp(ep.Properties.ObsNames,'TMbase'),:);
end