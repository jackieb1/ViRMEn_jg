function vr = initLinearTrackTrial_doubleLength(vr)
    vr.position(2) = vr.position(2) - vr.mazeLength/2;
    vr.trialTimer = tic;
    vr.numRewardsThisTrial = 0;