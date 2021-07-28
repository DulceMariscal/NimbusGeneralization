function [eps] = defineEpochVR_OG_UpdateV5(nantype, subjID)


names={'-MultiEnvSwitch','TMBaseNOVR','Adapt (\DeltaEMG_{on(-)})','SplitPos','TRbase','TMbase',...
    'Task_{Switch}','Post1-Adapt_{SS}','Post1_{Early}','Post1_{Late}','Post2_{e}-Post1_{l}','Post2_{Late}', 'WithinEnvSwitch (-\DeltaEMG_{on(+)})','PosShortLate','OG1Early'};

% og1CondName = 'OG 1';
% if nargin > 1 %subjID provided
%     if strcmp(subjID, 'CTR_02_2')
         og1CondName = 'OG base';
%     end
% end

if contains(subjID, 'CTS')
    posShortBase = 'TM fast';
else
    posShortBase = 'TM tied 1';
end

eps=defineEpochs(names,...
                {'OG base',posShortBase,'Neg Short','Pos Short','TR base','TM slow','Adaptation',...
                'Post 1','Post 1','Post 1','Post 2','Post 2','TM tied 1','Pos Short',og1CondName},...
                [-40 -40 20 20 -40 -40 -40 5 5 -40 5 -40 -40 -20 20],...
                [0,0,1,1,0,0,0,1,1,0,1,0,0,0,1],...
                [5,5,0,0,5,5,5,0,0,5,0,5,5,5,0],...
                nantype);