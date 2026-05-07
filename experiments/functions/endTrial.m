function vr = endTrial(vr)
vr.itiStartTime = tic;
vr.numTrials = vr.numTrials + 1;
vr = saveTrialData(vr);
vr = checkMaxRewards(vr);
vr.nextWorld = chooseNextWorld(vr);
