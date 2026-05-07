function vr = giveRewardPerDistance(vr)
    if vr.position(2) > (vr.lastRewardLocation + vr.rewardDistance)
        vr = giveRecordProbReward(vr, vr.correctRewardProbability);
        vr.lastRewardLocation = vr.position(2);
    end