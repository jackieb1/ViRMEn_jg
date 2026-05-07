function [vr] = stimYRange(vr)
    % check if within (ymin, ymax) for more than tmax time
    if vr.inITI == 1
        vr.stimOn = 0;
        % Reset timer
        vr.yRangeTimeStart = -1;
    elseif (vr.position(2) >= vr.optoYMin) && (vr.position(2) < vr.optoYMax)
        vr.stimOn = 1;
        if vr.yRangeTimeStart == -1
            % Start timer if not started
            vr.yRangeTimeStart = tic;
            disp('Stim On.');
        else
            if (vr.inITI == 0) && (toc(vr.yRangeTimeStart) > vr.maxStimOnTime_s)
                vr.stimOn = 0;
                disp('Stim timed out. Ending trial.');
                
                % End trial
                vr.dp = 0*vr.dp;
                vr.itiDur = vr.itiMiss;
                vr.nTimeOutTrials = vr.nTimeOutTrials + 1;
                if mod(vr.currentWorld,2)==1
                    % Note inverse from above because maze is flipped on screen
                    vr.rewardedSide = [vr.rewardedSide "R"];
                else
                    vr.rewardedSide = [vr.rewardedSide "L"];
                end
                vr.correctTrials = [vr.correctTrials 0];
                vr.worldTrials = [vr.worldTrials vr.currentWorld];
                vr.trialTimeTrials = [vr.trialTimeTrials toc(vr.trialTimer)];
                vr = endVRTrial(vr);
            end
        end
    else
        vr.stimOn = 0;
        vr.yRangeTimeStart = -1;
    end
    vr = triggerPhotoStimPC(vr, vr.stimOn);

end

