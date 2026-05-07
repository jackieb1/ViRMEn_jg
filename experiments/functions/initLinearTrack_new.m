function vr = initLinearTrack_new(vr)

% background color
vr.backgroundR_val = 0;
vr.backgroundG_val = 0;
vr.backgroundB_val = 0;
vr.rewardDelay = 0.2; % delay of 1s from reward zone entry until reward trigger

vr.numTrials = 0;
vr.numRewards = 0;
vr.nWorlds = length(vr.worlds);
vr.worldsAvailable = 1:vr.nWorlds;
vr.worldProbability = ones(1, vr.nWorlds)/vr.nWorlds;
vr.mazeLength = eval(vr.exper.variables.mazewidth);
vr.currentWorld = randsample(vr.worldsAvailable, 1);
vr.inITI = 0;
vr.itiCorrect = 3;  
vr.itiMiss = 7;
vr.trialIterations = 0;
vr.correctRewardProbability = ones(1, vr.nWorlds);
vr.incorrectRewardProbability = zeros(1, vr.nWorlds);
if ~vr.ops.useTeensyReward
    vr.ops.rewardPulseDuration = vr.ops.rewardPulseDurationDict(vr.rewardSize);
end

vr.correctTrials = [];
vr.rewardedSide = [];
vr.worldTrials = [];
vr.trialTimeTrials = [];
vr.leftTrials = [];
vr.turnSide = [];
% Bias Correction
vr.biasCorrection = false;
vr.biasCorrectionEps = 0.05;

vr.rewardsPerTrial = 1;
vr.sessionStartTime = tic;
vr.behaviorData = nan(9,1e4);
vr.trialTimer = tic;
vr.trialTimeTrials = [];
vr.correctRewardProbability = 1;
vr.numRewardsThisTrial = 0;
vr.numRewardsPerTrial = 1;
vr.forwardBias = 0;
vr.pitchGain = 1;
vr.sideGain = 1;
vr.inRewardZone = 0;