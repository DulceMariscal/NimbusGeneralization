function baseEp=getBaseEpochVR_OG()
ep=defineEpochVR_OG('nanmean');
baseEp=ep(strcmp(ep.Properties.ObsNames,'TMbase'),:);
end