function [vr] = checkforTrialEndPosition_L_maze(vr)
% check for trial-terminating position and deliver reward
if vr.inITI == 0 && ((vr.position(1) > vr.mazeLength + vr.cueLength-3) || (vr.position(2) > vr.mazeLength + vr.cueLength-3))
    % check if mouse is in reward zone mediolaterally, if 
    % Disable movement
    vr.dp = 0*vr.dp;
    % Enforce Reward Delay
    if ~vr.inRewardZone
        vr.rewStartTime = tic;
        vr.inRewardZone = 1;
    end
    vr.rewDelayTime = toc(vr.rewStartTime);
    if vr.rewDelayTime>vr.rewardDelay
        if (vr.origRewLoc == 1 && (vr.position(2) > vr.mazeLength + vr.cueLength-3)) || (vr.origRewLoc == 0 && (vr.position(1) > vr.mazeLength + vr.cueLength-3))
            vr = giveReward(vr,1);
            vr.behaviorData(9,vr.trialIterations) = 1;
            vr.numRewards = vr.numRewards + 1;
            vr.itiDur = 3;
        else
            vr.itiDur = 7;
        end
        vr = endTrialLinearMaze(vr);
    else
        vr.behaviorData(9,vr.trialIterations) = 0;
        vr.behaviorData(8,vr.trialIterations) = -1;
    end
else
    vr.behaviorData(9,vr.trialIterations) = 0; 
end
end

