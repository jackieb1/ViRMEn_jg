function [vr] = giveRecordUnexpectedReward(vr)
%giveRecordUnexpectedReward  Deliver this trial's unexpected (off-tower) reward.
%   Call once per trial when the animal first reaches vr.thisTrialUnexpectedY.
%   Counts into vr.numUnexpectedRewards, NOT vr.numRewards, so unexpected rewards do
%   not count toward the session-end reward limit.
%
%   behaviorData rows written here:
%     row 15 : 1 on the iteration the unexpected reward fired (0 elsewhere, set by the
%              maze code every iteration)
%   Row 9 is left alone - it stays reserved for tower and manual rewards.

    vr.numUnexpectedRewards         = vr.numUnexpectedRewards + 1;
    vr.thisTrialUnexpectedDelivered = 1;
    vr.behaviorData(15, vr.trialIterations) = 1;

    % giveReward's default 'Giving reward number <numRewards>' line counts tower
    % rewards only, so print our own line and silence giveReward's ('').
    disp(['Unexpected reward ', num2str(vr.numUnexpectedRewards), ...
          ' at y = ', num2str(vr.thisTrialUnexpectedY)]);
    vr = giveReward(vr, 1, [], '');   % session size (vr.rewardSize)
end
