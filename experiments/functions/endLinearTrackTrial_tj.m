function vr = endLinearTrackTrial_tj(vr)

    vr.numTrials = vr.numTrials + 1;
    vr.trialTimeTrials = [vr.trialTimeTrials toc(vr.trialTimer)];
    vr = saveTrialData(vr);
    vr = checkMaxRewards(vr);
    vr.worlds{vr.currentWorld}.surface.visible(:) = 0;
    vr.inITI = 1;
    vr.itiStartTime = tic;