function vr = endTrialWideLinearTrack(vr)
vr.correctTrials = [vr.correctTrials vr.isCorrect];
% vr.worldTrials = [vr.worldTrials vr.currentWorld];
vr.trialTimeTrials = [vr.trialTimeTrials toc(vr.trialTimer)];
vr.worlds{vr.currentWorld}.surface.visible(:) = 0;
vr.inITI = 1;

vr.itiStartTime = tic;
vr.numTrials = vr.numTrials + 1;
vr = saveTrialData(vr);
vr = checkMaxRewards(vr);