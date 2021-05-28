function baseEp=getBaseEpochNimbus()
ep=defineEpochNimbusShoes('nanmean');
baseEp=ep(strcmp(ep.Properties.ObsNames,'OGNimbus'),:);
end