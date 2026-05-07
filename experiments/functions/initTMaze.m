function [vr] = initTMaze(vr)
% Define world variables
vr.mazeLength = eval(vr.exper.variables.floorLength);
vr.floorLength = eval(vr.exper.variables.floorLength);
vr.cueLength = eval(vr.exper.variables.cueLength);
vr.bufferWidth = eval(vr.exper.variables.bufferWidth);
vr.floorWidth = eval(vr.exper.variables.floorWidth);
vr.nWorlds = length(vr.worlds);
vr.xRewardZoneThresh = 4*vr.floorWidth;

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

% Bias Correction
vr.biasCorrection = false;
vr.biasCorrectionEps = 0.05;

% Gain
vr.yawGain = 1;
vr.pitchGain = 1;
vr.forwardBias = 0;

%vr.mvThresh = 15;  
vr.friction = 0;  %.5 value adjust friction in collisions
vr.itiDur = 2;
vr.itiCorrect = 3;  
vr.itiMiss =7;
vr.mazeLength = eval(vr.exper.variables.floorLength);
vr.floorLength = eval(vr.exper.variables.floorLength);
vr.cueLength = eval(vr.exper.variables.cueLength);
vr.bufferWidth = eval(vr.exper.variables.bufferWidth);
vr.floorWidth = eval(vr.exper.variables.floorWidth);
vr.nWorlds = length(vr.worlds);
vr.worldsAvailable = 1:vr.nWorlds;
vr.worldProbability = ones(1, vr.nWorlds)/vr.nWorlds;
vr.xRewardZoneThresh = 12;
vr.inITI = 0;
vr.numTrials = 0;
vr.numRewards = 0;
vr.numCorrect = 0;
vr.dp = 0;
vr.isReward = 0;
vr.trialIterations = 0;
vr.wrongStreak = 0;
vr.inRewardZone = 0;
vr.filtSpeed = 0;
vr.targetRevealed = 0;
vr.sessionStartTime = tic;
vr.behaviorData = nan(9,1e4);
vr.trialTimer = tic;
vr.trialType = 1;
vr.currentWorld = randsample(vr.worldsAvailable, 1);
end

