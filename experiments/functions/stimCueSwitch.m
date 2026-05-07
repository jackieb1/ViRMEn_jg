function vr = stimCueSwitch(vr)

if vr.isStimTrial
    if (vr.position(2) < vr.optoYTrigger)
        vr.optoWasOn = 0;
    end
    
    if vr.stimOn == 1
        t = toc(vr.stimStartTime);
        % If done, turn off heading drift for next iter
        if t >= vr.maxStimOnTime_s
            vr.stimOn = 0;
            disp('Stim off.')
        end

    else
        % If triggered, turn on heading drift for next iter
        if (vr.position(2) >= vr.optoYTrigger) && (vr.optoWasOn == 0)
            vr.stimOn = 1;
            vr.optoWasOn = 1;
            vr.stimStartTime = tic;
            disp('Stim on.')
        end

    end
    vr = triggerPhotoStimPC(vr, vr.stimOn);
end
end