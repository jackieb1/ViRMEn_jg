function vr = changeGain(vr)

if vr.inGainChange == 1
    vr.yawGain = vr.yawGain2;
    vr.pitchGain = vr.pitchGain2;

    % If done, turn off gain change for next iter
    vr.gainChangeTime = toc(vr.gainChangeStartTime);
    if vr.gainChangeTime >= vr.gainChangeDuration
        vr.inGainChange = 0;
        disp('Stopped changing gain.');
    end

else
    vr.yawGain = vr.yawGain1;
    vr.pitchGain = vr.pitchGain1;

    % If triggered, turn on gain change for next iter
    if vr.position(2) >= vr.YTrigger
        vr.inGainChange = 1;
        vr.gainChangeStartTime = tic;
        vr.YTrigger = vr.totalMazeLength * 2; % reset y trigger until next trial (reset in chooseNextGainChangeYPosition)
        disp('Changing gain.');
    end

end