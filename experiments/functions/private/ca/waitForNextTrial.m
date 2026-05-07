function vr = waitForNextTrial(vr)

if vr.inITI == 1
    vr.filtSpeed = .8 * vr.filtSpeed + .2 * norm(vr.velocity);
    vr.itiTime = toc(vr.itiStartTime);
    if vr.itiTime > vr.itiDur
        if ~vr.debugMode
            isMouseStill = vr.filtSpeed < vr.mvThresh;
        else
            isMouseStill = 1;
        end
        if ~isMouseStill
            vr.worlds{vr.currentWorld}.backgroundColor = [1 1 1];
        else
            vr.worlds{vr.currentWorld}.backgroundColor = [0 0 0];
            vr.inITI = 0;
            vr = chooseNextWorld(vr);
            vr.position = vr.worlds{vr.currentWorld}.startLocation;
            vr.worlds{vr.currentWorld}.surface.visible(:) = 1;
            vr.dp = 0;
            vr.inRewardZone = 0;
            vr.trialTimer = tic;
            vr.trialStartTime = rem(now,1);
        end
    end
end