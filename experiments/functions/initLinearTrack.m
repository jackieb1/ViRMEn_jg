function vr = initLinearTrack(vr)

vr.numTrials = 0;
vr.numRewards = 0;

vr.currentWorld = 1;
vr.inITI = 0;
vr.trialIterations = 0;
if ~vr.ops.useTeensyReward
    vr.ops.rewardPulseDuration = vr.ops.rewardPulseDurationDict(vr.rewardSize);
end
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
vr.nWorlds = length(vr.worlds);
vr.worldsAvailable = 1:vr.nWorlds;
vr.worldProbability = ones(1, vr.nWorlds)/vr.nWorlds;