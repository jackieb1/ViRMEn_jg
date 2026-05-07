function [vr] = initBoxMaze(vr)
% Define world variables
vr.boxLength = eval(vr.exper.variables.boxLength);
vr.boxWidth = eval(vr.exper.variables.boxWidth);
vr.rewardPortLength = eval(vr.exper.variables.rewardPortLength);
vr.smallRadius =  eval(vr.exper.variables.smallRadius);
vr.nWorlds = length(vr.worlds);

% background color
vr.backgroundR_val = 0;
vr.backgroundG_val = 0;
vr.backgroundB_val = 0;
vr.rewardDelay = 0.2; % delay of 1s from reward zone entry until reward trigger

% Reward
vr.correctRewardProbability = ones(1, vr.nWorlds);
vr.incorrectRewardProbability = zeros(1, vr.nWorlds);
if ~vr.ops.useTeensyReward
    vr.ops.rewardPulseDuration = vr.ops.rewardPulseDurationDict(vr.rewardSize);
end
vr.rewardsPerTrial = 1;
vr.correctTrials = [];
vr.rewardedSide = [];
vr.worldTrials = [];
vr.trialTimeTrials = [];
vr.leftTrials = [];
vr.turnSide = [];

% Gain
vr.sideGain = 1;
vr.pitchGain = 1;
vr.forwardBias = 0;

%vr.mvThresh = 15; 
vr.biasCorrection = false;
vr.friction = 0;  %.5 value adjust friction in collisions
vr.itiDur = 2;
vr.trialTimer = tic;
% vr.itiCorrect = 3;
% vr.itiMiss =7;
vr.yRewardZoneThresh = vr.boxLength + vr.rewardPortLength - vr.smallRadius - 1;
vr.worldsAvailable = 1:vr.nWorlds;
vr.worldProbability = ones(1, vr.nWorlds)/vr.nWorlds;
vr.xRewardZoneThresh = 12;
vr.inITI = 0;
vr.numTrials = 0;
vr.numRewards = 0;
vr.numRewardsPerTrial = 1;
vr.numCorrect = 0;
vr.dp = 0;
vr.isReward = 0;
vr.trialIterations = 0;
vr.inRewardZone = 0;
vr.sessionStartTime = tic;
vr.behaviorData = nan(9,1e4);
vr.currentWorld = randsample(vr.worldsAvailable, 1);
end

