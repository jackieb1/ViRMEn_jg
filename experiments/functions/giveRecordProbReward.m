function [vr] = giveRecordProbReward(vr, probability)
    if rand <= probability
        vr = giveReward(vr, vr.rewardsPerTrial);
        vr.behaviorData(9,vr.trialIterations) = vr.rewardsPerTrial;
        vr.numRewards = vr.numRewards + vr.rewardsPerTrial;
    else
        vr.behaviorData(9,vr.trialIterations) = 0;
    end
end
