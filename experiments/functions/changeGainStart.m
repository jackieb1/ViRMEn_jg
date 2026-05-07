function vr = changeGainStart(vr)

if vr.inGainChange == 1
    vr.pitchGain = vr.newGain;

    % If done, turn off gain change for next iter
    vr.gainChangeTime = toc(vr.gainChangeStartTime);
    if vr.gainChangeTime >= vr.gainChangeDuration
        vr.inGainChange = 0;
        disp('Stopped changing gain.');
    end

else
    vr.pitchGain = 1.0;
end