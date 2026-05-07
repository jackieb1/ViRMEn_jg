function vr = waitForNextTrial_opto(vr)

if vr.inITI == 1
    vr.worlds{vr.currentWorld}.backgroundColor = [0 0 0];
    vr.itiTime = toc(vr.itiStartTime);
end
