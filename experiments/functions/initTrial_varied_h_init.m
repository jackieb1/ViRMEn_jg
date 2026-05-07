function vr = initTrial_varied_h_init(vr)
    vr.inITI = 0;
    vr = setWorld(vr, vr.nextWorld);
    vr.dp = deg2rad(randi([-90, 90]));
    vr.inRewardZone = 0;
    vr.trialTimer = tic;
    vr.trialStartTime = rem(now,1);
end