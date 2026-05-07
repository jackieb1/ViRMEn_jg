function vr = headingDriftPulse(vr)

if vr.inDriftPulse
    t = toc(vr.pulseStartTime);
    vr.dp4offset = gauss(t, vr.driftPulseMu, vr.driftPulseSd) * vr.driftPulseHeight;
    vr.dp(4) = vr.dp(4) + vr.dp4offset;

    % If done, turn off heading drift for next iter
    if t >= vr.driftPulseSd * 8
        vr.inDriftPulse = 0;
        vr.dp4offset = 0;
        disp('Drift end.');
    end

else
    % If triggered, turn on heading drift for next iter
    if (vr.position(2) >= vr.YTrigger) && (~vr.pulseWasOn)
        vr.pulseWasOn = true;
        vr.inDriftPulse = 1;
        vr.pulseStartTime = tic;
        vr.XTrigger = 10000;
        disp('Drift start.');
    end

end

end