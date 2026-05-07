function vr = endTrialLinearMaze(vr)
vr.worldTrials = [vr.worldTrials vr.currentWorld];
vr.trialTimeTrials = [vr.trialTimeTrials toc(vr.trialTimer)];
vr.worlds{vr.currentWorld}.surface.visible(:) = 0;
vr.inITI = 1;
vr = endTrial(vr);
disp('Trial End')