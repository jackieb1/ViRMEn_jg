function vr = checkExecuteStim_timeOut(vr)
    switch vr.stimTrialSegment
        case 'wholeTrial'
            if vr.inITI
                if (vr.itiTime > (vr.itiDur - vr.stimRampTime))
                    if vr.nextTrialIsStim  && (vr.optoWasOn == 0)
                        % Turn on stim at end of ITI if next trial is stim
                        vr.stimOn = 1;
                        disp('Stim On.')
                        vr.optoWasOn = 1;
                        vr.stimOnTimer = tic;
                    end
                else
                    % Turn off stim when entering ITI
                    vr.stimOn = 0;
                    vr.optoWasOn = 0;
                end
            else
                if vr.stimOn
                    % Turn off stim if on for more than vr.maxStimOnTime
                    timeSinceStimOn = toc(vr.stimOnTimer);
                    if timeSinceStimOn >= vr.maxStimOnTime
                        vr.numTimeOuts = vr.numTimeOuts + 1;
                        vr.itiDur = vr.itiMiss;
                        vr = endVRTrial(vr);
                    end
                end
            end
            
        case 'yTrigger'
            if vr.isStimTrial
                % Turn on after cross vr.optoYTrigger for the first time
                if (vr.position(2) >= vr.optoYTrigger) && (vr.optoWasOn == 0)
                    vr.stimOn = 1;
                    disp('Stim On.')
                    vr.optoWasOn = 1;
                    vr.stimOnTimer = tic;
                end

                % Turn off if reach ITI
                if vr.inITI
                    vr.stimOn = 0;
                end

                % Turn off after vr.maxStimOnTime_s
                if vr.stimOn
                    timeSinceStimOn = toc(vr.stimOnTimer);
                    if timeSinceStimOn >= vr.maxStimOnTime_s
                        vr.stimOn = 0;
                    end
                end
            else
                vr.stimOn = 0;
            end

        otherwise
            error('Invalid value for vr.stimTrialSegment.')
    end
    
    vr = triggerPhotoStimPC(vr, vr.stimOn);

end

