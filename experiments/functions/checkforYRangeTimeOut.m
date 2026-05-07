function [vr] = checkforYRangeTimeOut(vr)
    % check if within (ymin, ymax) for more than tmax time
    if (vr.position(2) >= vr.optoYMin) && (vr.position(2) < vr.optoYMax)
        vr.stimOn = 1;
        if vr.yRangeTimeStart == -1
            % Start timer if not started
            vr.yRangeTimeStart = tic;
            disp('Stim On.');
        else
            
            if toc(vr.yRangeTimeStart) > vr.maxStimOnTime_s
                disp('Stim timed out. Ending trial.');
%                 vr.dp = 0*vr.dp;
%                 vr.itiDur = vr.itiMiss;
%                 
%                 vr.correctTrials = [vr.correctTrials nan];
%                 vr.worldTrials = [vr.worldTrials vr.currentWorld];
%                 vr.trialTimeTrials = [vr.trialTimeTrials toc(vr.trialTimer)];
%                 vr = endVRTrial(vr);
            end
        end
    elseif vr.inITI
        vr.stimOn = 0;
        % Reset timer
        vr.yRangeTimeStart = -1;
    else
        vr.stimOn = 0;
        vr.yRangeTimeStart = -1;
    end
    vr = triggerPhotoStimPC(vr, vr.stimOn);

end

