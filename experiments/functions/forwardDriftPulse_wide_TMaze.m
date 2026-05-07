function vr = forwardDriftPulse_wide_TMaze(vr)

if vr.inDriftPulse == 1
    t = toc(vr.pulseStartTime);
    if t <= vr.driftPulseMu
        vr.forwardBias = gauss(t, vr.driftPulseMu, vr.driftPulseSd) * vr.driftPulseHeight;
    elseif t < (vr.driftPulseMu + vr.driftConstantLength)
        vr.forwardBias = gauss(vr.driftPulseMu, vr.driftPulseMu, vr.driftPulseSd) * vr.driftPulseHeight;
    else
        vr.forwardBias = gauss(t - vr.driftConstantLength, vr.driftPulseMu, vr.driftPulseSd) * vr.driftPulseHeight;
    end
    if (vr.position(2) + vr.dp(2) + vr.forwardBias > 1) && (vr.position(2) + vr.dp(2) + vr.forwardBias < 307) && (abs(vr.position(1) + vr.dp(1)) < 1)
        vr.dp(2) = vr.dp(2) + vr.forwardBias;
    else
        disp('Prevent pulse from exiting maze');
        vr.dp(2) = 0;
    end

    % If done, turn off heading drift for next iter
%     disp(t);
    if t >= vr.driftTime
        vr.inDriftPulse = 0;
        vr.forwardBias = 0;
        disp('Drift end.');
    end

else
    % If triggered, turn on heading drift for next iter
    if (vr.position(2) >= vr.driftYTrigger)
        vr.inDriftPulse = 1;
        vr.pulseStartTime = tic;
        vr.driftYTrigger = vr.totalMazeLength * 4; % reset y trigger until next trial (reset in chooseNextGainChangeYPosition)
        disp('Drift start.');
    end

end

end