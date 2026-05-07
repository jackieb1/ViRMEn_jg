function vr = giveRewardPerLocation(vr)
    if (vr.position(2) > vr.rewardLocation) && (vr.numRewardsThisTrial < vr.numRewardsPerTrial)
        vr = giveRecordProbReward(vr, vr.correctRewardProbability);
        vr.numRewardsThisTrial = vr.numRewardsThisTrial + 1;
    else
        vr.behaviorData(9,vr.trialIterations) = 0;
    end