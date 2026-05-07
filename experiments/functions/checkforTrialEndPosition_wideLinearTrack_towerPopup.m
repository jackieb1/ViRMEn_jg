function [vr] = checkforTrialEndPosition_wideLinearTrack_towerPopup(vr)
    % check for trial-terminating position and deliver reward
    if (vr.inITI == 0) && (vr.position(2) > vr.towerPopupLocation)
        % Disable movement
        vr.dp = 0*vr.dp;
        
        vr.isCorrect = abs(vr.position(1)-vr.rewardXLocation) < vr.rewardZoneRadius;
        % Enforce Reward Delay
        if ~vr.inRewardZone
            vr.currentWorld = vr.worldBlock;
            vr.rewStartTime = tic;
            vr.inRewardZone = 1;
        end
        vr.rewDelayTime = toc(vr.rewStartTime);
        vr.worlds{vr.currentWorld}.surface.visible(:) = 1;
        if vr.rewDelayTime > vr.rewardDelay
            if vr.isCorrect
                vr = giveReward(vr, vr.numRewardsPerTrial);
                vr.behaviorData(9,vr.trialIterations) = 1;
                vr.numRewards = vr.numRewards + vr.numRewardsPerTrial;
                vr.itiDur = vr.itiCorrect;
            else
                vr.behaviorData(9,vr.trialIterations) = 0;
                vr.itiDur = vr.itiMiss;
            end
            vr = endTrialWideLinearTrack(vr);
        else
            vr.behaviorData(9,vr.trialIterations) = 0;
        end
    else
        vr.behaviorData(9,vr.trialIterations) = 0; 
    end
end

