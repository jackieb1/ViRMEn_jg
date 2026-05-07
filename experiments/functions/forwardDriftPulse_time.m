function vr = forwardDriftPulse_time(vr)

if vr.inDriftPulse == 1
    t = toc(vr.pulseStartTime);
    vr.forwardBias = gauss(t, vr.driftPulseMu, vr.driftPulseSd) * vr.driftPulseHeight;
    if (vr.position(2) + vr.dp(2) + vr.forwardBias > 10) && (vr.position(2) + vr.dp(2) + vr.forwardBias < 300)
        vr.dp(2) = vr.dp(2) + vr.forwardBias;
    end

    % If done, turn off heading drift for next iter
    if (t >= vr.driftTime) || (vr.inITI == true)
        vr.inDriftPulse = 0;
        vr.forwardBias = 0;
        vr.pulsed = 1;
        disp('Drift end.');
    end

else
    % If triggered, turn on heading drift for next iter
    if (vr.timeFromYThresh >= vr.pulseTime) && (vr.isPulseTrial == 1) && (vr.pulsed == 0)
        vr.inDriftPulse = 1;
        vr.pulseStartTime = tic;
        disp('Drift start.');
    end

end

end