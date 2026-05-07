function vr = endLinearTrackTrial(vr)

    vr.numTrials = vr.numTrials + 1;
    vr.trialTimeTrials = [vr.trialTimeTrials toc(vr.trialTimer)];
    vr = saveTrialData(vr);
    vr = checkMaxRewards(vr);
    