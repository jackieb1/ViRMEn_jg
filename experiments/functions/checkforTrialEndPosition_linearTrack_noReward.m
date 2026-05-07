function [vr] = checkforTrialEndPosition_linearTrack_noReward(vr)
% check for trial-terminating position and deliver reward
if vr.inITI == 0 && (vr.position(2) > vr.mazeLength)
    % check if mouse is in reward zone mediolaterally, if 
    % Disable movement
%     disp('in reward zone');
    vr.dp = 0*vr.dp;
    vr.itiDur = vr.itiCorrect;
    vr = endTrialLinearMaze(vr);
else
    vr.behaviorData(9,vr.trialIterations) = 0; 
end
end

