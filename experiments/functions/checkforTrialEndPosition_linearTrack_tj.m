function [vr] = checkforTrialEndPosition_linearTrack_tj(vr)

if vr.inITI == 0 && (vr.position(2) > vr.mazeLength-20)
    vr.dp = 0*vr.dp;
    vr.currentWorld = 1;
    vr.itiDur = 2;
    vr = endLinearTrackTrial_tj(vr);
end

end

