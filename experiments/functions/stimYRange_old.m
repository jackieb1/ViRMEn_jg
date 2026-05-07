function vr = stimYRange_old(vr)

if vr.isStimTrial
    if (vr.position(2) < vr.optoYMin) || (vr.position(2) >= vr.optoYMax)
        vr.stimOn = 0;
    end
    
    if vr.stimOn == 1
        t = toc(vr.stimStartTime);
        % If done, turn off heading drift for next iter
        if t >= vr.maxStimOnTime_s
            vr.stimOn = 0;
            disp('Stim on timed out. Stim off.')
            vr.stimOffTime = tic;
        end

    else
        if vr.optoWasOn
            if ( toc(vr.stimOffTime) > vr.maxStimOffTime_s)
                disp('Stim off timed out.')
                vr.optoWasOn = 0;
            end
        end
        % If triggered, turn on heading drift for next iter
        if (vr.position(2) >= vr.optoYMin) && (vr.position(2) < vr.optoYMax) && (vr.optoWasOn == 0)
            vr.stimOn = 1;
            vr.optoWasOn = 1;
            vr.stimStartTime = tic;
            disp('Stim on.')
        end

    end
    vr = triggerPhotoStimPC(vr, vr.stimOn);
end
end