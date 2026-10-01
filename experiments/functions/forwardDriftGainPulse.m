function vr = forwardDriftGainPulse(vr)

if vr.inDriftPulse == 1
    t = toc(vr.pulseStartTime);
    switch vr.pulseType
        case {1,2} % forward/backward gaussian offset
            vr.forwardBias = gauss(t, vr.driftPulseMu, vr.driftPulseSd) * vr.driftPulseHeight;
        case 3 % zero gain
            vr.pitchGain = 0;
        case 4 % \_/ gain: ramp 1 -> 0, hold 0, ramp 0 -> 1 (thirds of driftTime)
            u = 3*t/vr.driftTime;
            vr.pitchGain = min(1, max([0, 1-u, u-2]));
    end

    % If done, turn off pulse for next iter
    if t >= vr.driftTime
        vr.inDriftPulse = 0;
        vr.forwardBias = 0;
        vr.pitchGain = 1;
        disp('Drift end.');
    end

else
    % If triggered, turn on pulse for next iter
    if (vr.position(2) >= vr.driftYTrigger)
        vr.inDriftPulse = 1;
        vr.pulseStartTime = tic;
        vr.driftYTrigger = vr.totalMazeLength * 2; % reset y trigger until next trial
        disp('Drift start.');
    end

end

end
