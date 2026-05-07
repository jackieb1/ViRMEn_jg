function rearmIfIdle(vr)
    try
        if ~vr.keepRunning, return; end
        if ~vr.ao.IsRunning && vr.ao.ScansQueued==0
            outputSingleScan(vr.ao,0);          % force baseline
            queueOutputData(vr.ao, vr.yPulse);          % preload next pulse
            startBackground(vr.ao);             % RE-ARM: wait for next PFI0 edge
        end
    catch, end
end