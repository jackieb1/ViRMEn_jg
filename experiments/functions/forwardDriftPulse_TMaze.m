function vr = forwardDriftPulse_TMaze(vr)

if vr.inDriftPulse == 1
    t = toc(vr.pulseStartTime);
    vr.forwardBias = gauss(t, vr.driftPulseMu, vr.driftPulseSd) * vr.driftPulseHeight;
    if (vr.position(2) + vr.dp(2) + vr.forwardBias > 1) && (vr.position(2) + vr.dp(2) + vr.forwardBias < 307)
        vr.dp(2) = vr.dp(2) + vr.forwardBias;
    else
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