function vr = sidePulse(vr)

    if vr.inPulse == 1
        t = toc(vr.pulseStartTime);
        vr.sideOffset = gauss(t, vr.pulseMu, vr.pulseSd) * vr.pulseHeight;
    
        % If done, turn off heading drift for next iter
        if t >= vr.pulseSd * 8
            vr.inPulse = 0;
            vr.sideOffset = 0;
            disp('Drift end.');
        end
    
    else
        % If triggered, turn on heading drift for next iter
        if vr.isPulseTrial && ~vr.pulseWasTriggered && (vr.position(2) >= vr.pulseYTrigger)
            vr.inPulse = 1;
            vr.pulseWasTriggered = 1;
            vr.pulseStartTime = tic;
            disp('Drift start.');
        end
    
    end

end