function [vr] = checkforTrialEndPosition_linearTrack_hk(vr)
% No Reward during ITI
% check for trial-terminating position
if vr.inITI == 0 && (vr.position(2) > vr.mazeLength)
    % Disable movement
    vr.dp = 0*vr.dp;
    vr.itiDur = 3;
%     disp(vr.worlds{vr.currentWorld}.backgroundColor)
    vr.backgroundR_val = vr.worlds{vr.currentWorld}.backgroundColor(1);
    vr.backgroundG_val = vr.worlds{vr.currentWorld}.backgroundColor(1);
    vr.backgroundB_val = vr.worlds{vr.currentWorld}.backgroundColor(1);
    vr = endLinearTrackTrial(vr);
    vr = endTrialLinearMaze_hk(vr);
else
    vr.behaviorData(9,vr.trialIterations) = 0; 
end
end

