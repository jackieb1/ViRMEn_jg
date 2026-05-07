function vr = checkExecuteStim(vr)
    if vr.isStimTrial
        switch vr.stimTrialSegment
            case 'wholeTrial'
                if vr.inITI == 0
                    % End stim after vr.maxStimTime
                    timeSinceStimOn = toc(vr.trialTimer);
                    if timeSinceStimOn < vr.maxStimOnTime_s
                        vr.stimOn = 1;
                    else
                        vr.stimOn = 0;
                    end
                else
                    vr.stimOn = 0;
                end
            case 'yTrigger'
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
                
            otherwise
                error('Invalid value for vr.stimTrialSegment.')
        end
    else
        vr.stimOn = 0;
    end
    vr = triggerPhotoStimPC(vr, vr.stimOn);

end

