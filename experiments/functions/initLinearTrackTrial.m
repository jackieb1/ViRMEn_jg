function vr = initLinearTrackTrial(vr)
    vr.position(2) = vr.position(2) - vr.mazeLength + vr.dp(2);
    vr.trialTimer = tic;
    vr.numRewardsThisTrial = 0;