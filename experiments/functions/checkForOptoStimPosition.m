function [vr] = checkForOptoStimPosition(vr)
% check for opto-triggering position
    if vr.inITI == 0 && (vr.position(2) > vr.optoLocation) && ~vr.optoFired && vr.currentWorld>2
        vr = outputOptoTrigger(vr); % sends a TTL pulse and sets vr.optoFired = true;
    end
end