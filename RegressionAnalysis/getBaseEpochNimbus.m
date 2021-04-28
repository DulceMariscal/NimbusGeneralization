function baseEp=getBaseEpochNimbus()
ep=defineEpocNimbusShoes('nanmean');
baseEp=ep(strcmp(ep.Properties.ObsNames,'OGNimbus'),:);
end