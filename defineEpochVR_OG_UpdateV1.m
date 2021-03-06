function [eps] = defineEpochVR_OG_UpdateV1(nantype)


names={'OGbase','TMBaseNOVR','\DeltaEMG_{on(-)}','SplitPos','Env_{Switch}','TMBase',...
    'Task_{Switch}','OGpost-Adapt_{SS}','OGpost_{Early}','OGpost_{Late}','TMPost_{Early}','TMPost_{Late}','TMbase'};

eps=defineEpochs(names,...
                {'OG base','TM tied 1','Neg Short','Pos Short','TM Base','TM base','Adaptation',...
                'OG post','OG post','OG post','TM post','TM post','TM Base'},...
                [-40 -40 20 20 -40 -40 -40 20 20 -40 20 -40 -40],...
                [0,0,1,1,0,0,0,1,1,0,1,0, 0 ],...
                [5,5,0,0,5,5,5,0,0,5,0,5, 5],...
                nantype);