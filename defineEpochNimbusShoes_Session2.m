function [eps] = defineEpochNimbusShoes_Session2(nantype, subjID)

% names={'Base', 'EarlyA', 'LateA' ,'EarlyP', 'LateP'};

names={'Base','TMBaseFast','PostShortFromShoes','OG 1','Pos Short 2','OG 2','Neg Short 2','OG 3','TM fast','TM tied 2','TM tied 3'};

% if strcmp(subjID, 'NTR_02')
%     exemptFirstShortSplit = 23;
% elseif strcmp(subjID, 'NTR_03')
%     exemptFirstShortSplit = 24;
% elseif strcmp(subjID, 'NTR_04')
%     exemptFirstShortSplit = 17;  
% else
exemptFirstShortSplit = 1;
% end
exemptFirstShortSplit

eps=defineEpochs(names,...
                {'OG base','TM fast','Short split','OG 1','Pos Short','OG 2','Neg Short','OG 3','TM fast','TM tied 2','TM tied 3'},...
                [-40 -40 20 20 20 20 20 20 -40 -40 -40],...
                [0,0,exemptFirstShortSplit,1,1,1,1,1,0,0,0],...
                [5,5,0,0,0,0,0,0,5,5,5],...
                nantype);
%             Temp change,  during short split for NTR02, ignore first 23
%             strides (bad strides), use 20 strides, exempt first 23 (the #
%             of strides do not include the exempted strides)
%             Temp change,  during short split for NTR03, ignore first 24 strides (bad strides)