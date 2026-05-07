function [vr] = checkforTrialEndPosition(vr)
% check for trial-terminating position and deliver reward
if vr.inITI == 0 && (vr.position(2) > vr.mazeLength + 2) && (abs(vr.position(1))>0.5*vr.floorWidth)
    % check if mouse is in reward zone mediolaterally, if 
    % Disable movement
    vr.dp = 0*vr.dp;
    % Enforce Reward Delay
    if ~vr.inRewardZone
        vr.rewStartTime = tic;
        vr.inRewardZone = 1;
    end
    vr.rewDelayTime = toc(vr.rewStartTime);    
    if vr.rewDelayTime > vr.rewardDelay   
        vr.behaviorData(9,vr.trialIterations) = 1;
        vr.numRewards = vr.numRewards + 1;
        %vr = giveReward_stepperMotor(vr,1,vr.sm);
        vr.itiDur = vr.itiCorrect;
        vr = endVRTrial(vr);
    else
        vr.behaviorData(9,vr.trialIterations) = 0;
        vr.behaviorData(8,vr.trialIterations) = -1;
    end
else
    vr.behaviorData(9,vr.trialIterations) = 0;
end
end

