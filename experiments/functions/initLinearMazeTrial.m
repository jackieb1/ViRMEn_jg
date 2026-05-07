function vr = initLinearMazeTrial(vr)
     vr.inITI = 0;
    vr.position = vr.worlds{vr.currentWorld}.startLocation;
    vr.worlds{vr.currentWorld}.surface.visible(:) = 1;
    vr.worlds{vr.currentWorld}.backgroundColor = [vr.backgroundR_val vr.backgroundG_val vr.backgroundB_val];
    vr.currentWorld=1;
    vr.dp = 0*vr.dp;
    vr.inRewardZone = 0;
    vr.trialTimer = tic;
    vr.trialStartTime = rem(now,1);
end