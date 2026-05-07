function [vr] = checkForManualReward(vr)
manualReward = vr.keyPressed == 82; %'r' key
if manualReward
    vr.behaviorData(9,vr.trialIterations) = 1;
    vr.numRewards = vr.numRewards + 1;
    vr = giveReward(vr,1);
end
end
