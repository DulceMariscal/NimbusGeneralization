function [eps] = defineEpochNIM_OG_UpdateV4(nantype, subjID)


% names={'WithinEnvSwitch (-\DeltaEMG_{on(+)})2','Adapt (\DeltaEMG_{on(-)})2','PosShort','ShortSplit','WithinEnvSwitchFromShoe (-\DeltaEMG_{on(+)})2','PosSplit_{late} - OG_{post}(-\DeltaEMG_{off(+)})','ShoeSplit_{late} - OG_{post}(-Shoe\DeltaEMG_{off(+)})','OGPostShoe','OGPostPosShort','NegSplit_{late} - OG_{post}(-\DeltaEMG_{off(-)})','SwapShoeSplit_{late} - OG_{post}(-Shoe\DeltaEMG_{off(-)})','OGPostNegShort','-\DeltaEMG_{on(-)}'};
names={'WithinEnvSwitch (-\DeltaEMG_{on(+)})2','Adapt (\DeltaEMG_{on(-)})2','PosShort','ShortSplit','-Shoe\DeltaOn(+)2','-\Deltaoff(+)','-Shoe\Deltaoff(+)','OGPostShoe','OGPostPosShort','-\Deltaoff(-)','-Shoe\Deltaoff(-)','OGPostNegShort','-\Deltaon(-)','TMslow'};

% if strcmp(subjID, 'NTR_02')
%     exemptFirstShortSplit = 23;
% elseif strcmp(subjID, 'NTR_03')
%     exemptFirstShortSplit = 24;
% elseif strcmp(subjID, 'NTR_04')
%     exemptFirstShortSplit = 17;    
% elseif  strcmp(subjID, 'NTR')
%     exemptFirstShortSplit = 24; 
% else
    exemptFirstShortSplit = 1;
% end
exemptFirstShortSplit

eps=defineEpochs(names,...
                {'TM tied 2','Neg Short','Pos Short','Short split','TM fast','Pos Short','Short split','OG 1','OG 2','Neg Short','Short split','OG 3','TM tied 3','TM slow'},...
                [-40 20 20 20 -40 -20 -20 20 20 -20 -20 20 -40, -40],...
                [0,1,1,exemptFirstShortSplit,0,0,0,1,1,0,0,1,0,0],...
                [5,0,0,0,5,5,5,0,0,5,5,0,5,5],...
                nantype);
%    NTR02: 20 ignore first 23
%    NTR03: ignore first 24