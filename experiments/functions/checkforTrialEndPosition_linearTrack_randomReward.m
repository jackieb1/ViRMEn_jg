function [vr] = checkforTrialEndPosition_linearTrack_randomReward(vr)
% check for trial-terminating position and deliver reward
if vr.inITI == 0 && (vr.position(2) > vr.mazeLength)
    
    % Disable movement
    vr.dp = 0*vr.dp;

    % Enforce Reward Delay
    if ~vr.inRewardZone
        vr.rewStartTime = tic;
        vr.inRewardZone = 1;
    end
    
    vr.rewDelayTime = toc(vr.rewStartTime);
    if vr.rewDelayTime > vr.rewardDelay
        vr = giveRecordProbReward(vr, vr.correctRewardProbability(vr.currentWorld));
        vr.itiDur = vr.itiCorrect;
        vr = endTrialLinearMaze(vr);
    else
        vr.behaviorData(9,vr.trialIterations) = 0;
        vr.behaviorData(8,vr.trialIterations) = -1;
    end
else
    vr.behaviorData(9,vr.trialIterations) = 0; 
end
end

