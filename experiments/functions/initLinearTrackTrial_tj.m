function vr = initLinearTrackTrial_tj(vr)
    vr.position(2) = vr.position(2) - (vr.mazeLength-20);
    vr.trialTimer = tic;
    vr.numRewardsThisTrial = 0;
    vr.inITI = 0;
    vr.currentWorld = 1;
    vr.position = vr.worlds{1}.startLocation;
    vr.worlds{1}.surface.visible(:) = 1;    