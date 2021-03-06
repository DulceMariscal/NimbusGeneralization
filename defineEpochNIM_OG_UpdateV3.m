function [eps] = defineEpochNIM_OG_UpdateV3(nantype)


names={'OGBase','TMBaseFast','Neg Short','Pos Short',...
    'TR base','NIMBase','Adaptation','Post1-Adapt_{SS}',...
    'Post1_{Early}','Post1_{Late}','Post2_{Early}','Post2_{Late}',...
    'NIM Base'};

eps=defineEpochs(names,...
                {'OG base','TM tied 1','Neg Short','Pos Short',...
                'TR base','TR base', 'Adaptation','Post 1',...
                'Post 1','Post 1','Post 2','Post 2',...
                'TR base'},...
                [-40 -40 20 20,...
                -40 -40 -40 5,...
                5 -40 5 -40,...
                -40],...
                [0,0,1,1,...
                0,0,0,1,...
                1,0,1,0,...
                0],...
                [5,5,0,0,...
                5,5,5,0,...
                0,5,0,5,...
                5],...
                nantype);
   