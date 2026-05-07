function [vr] = initTMaze_opto(vr)
% background color
vr.backgroundR_val = 0;
vr.backgroundG_val = 0;
vr.backgroundB_val = 0;
vr.rewardDelay = 0.2; % delay of 1s from reward zone entry until reward trigger
%vr.mvThresh = 15;  
vr.friction = 0;  %.5 value adjust friction in collisions
vr.itiDur =2;
vr.itiCorrect = 3;  
vr.itiMiss =7;
vr.mazeLength = eval(vr.exper.variables.floorLength);
vr.floorLength = eval(vr.exper.variables.floorLength);
vr.cueLength = eval(vr.exper.variables.cueLength);
vr.bufferWidth = eval(vr.exper.variables.bufferWidth);
vr.floorWidth = eval(vr.exper.variables.floorWidth);
vr.nWorlds = length(vr.worlds);
vr.optoLocation = eval(vr.exper.variables.optoLocation);
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
% setup for opto
vr.currentTrial = 1;
vr.trialList = getTrialList;
vr.optoFired = false;

vr.sessionStartTime = tic;
vr.behaviorData = nan(9,1e4);
vr.trialTime = tic;
end

