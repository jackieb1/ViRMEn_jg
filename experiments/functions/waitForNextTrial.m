function vr = waitForNextTrial(vr)

if vr.inITI
    vr.worlds{vr.currentWorld}.backgroundColor = [0 0 0];
    vr.itiTime = toc(vr.itiStartTime);
    %disp(['ITI time:' num2str(vr.itiTime)])
end