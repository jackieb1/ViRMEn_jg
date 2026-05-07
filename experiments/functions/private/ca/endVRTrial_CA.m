function vr = endVRTrial_CA(vr)

vr.worlds{vr.currentWorld}.surface.visible(:) = 0;
%vr.worlds{vr.currentWorld}.backgroundColor = [0.5 0.5 0.5];
vr.worlds{vr.currentWorld}.backgroundColor = [0.55 0.55 0.55]; % 170613: make ITI color same as grey background color

%vr.dp = 0*vr.dp;
vr.itiStartTime = tic;
vr.inITI = 1;
vr.numTrials = vr.numTrials + 1;

%save trial data
vr = saveTrialData(vr);