function [vr] = initLinearTrack_dan(vr)
% background color
vr.backgroundR_val = eval(vr.exper.variables.backgroundR_val);
vr.backgroundG_val = vr.backgroundR_val;
vr.backgroundB_val = vr.backgroundR_val;
vr.rewardDelay = 1; % delay of 1s from reward zone entry until reward trigger
%vr.mvThresh = 15;  
vr.friction = 0.5;  %.5 value adjust friction in collisions
vr.itiCorrect = 1;  
vr.itiMiss = 0;
vr.mazeLength = eval(vr.exper.variables.floorLength);
vr.nWorlds = length(vr.worlds);
vr.inITI = 0;
vr.numTrials = 0;
vr.numRewards = 0;
vr.dp = 0;
vr.isReward = 0;
vr.trialIterations = 0;
vr.wrongStreak = 0;
vr.inRewardZone = 0;
vr.filtSpeed = 0;
vr.targetRevealed = 0;
vr.sessionStartTime = tic;
vr.behaviorData = nan(9,1e4);
% added by CA to introduce switches dynamically
vr.switches = 0;
end

