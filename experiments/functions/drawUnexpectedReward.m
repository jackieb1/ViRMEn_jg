function vr = drawUnexpectedReward(vr)
%drawUnexpectedReward  Decide whether the upcoming trial gets an unexpected reward.
%   Call once per trial: in initialization for trial 1, then at every trial end for
%   the next trial. Each trial is drawn independently with probability
%   vr.unexpectedRewardFraction; on an unexpected-reward trial one of the
%   vr.unexpectedRewardYLocations is picked with equal probability.

    vr.thisTrialUnexpectedDelivered = 0;
    if rand < vr.unexpectedRewardFraction
        vr.thisTrialUnexpected  = 1;
        vr.thisTrialUnexpectedY = vr.unexpectedRewardYLocations(randi(vr.unexpectedRewardNumLocations));
    else
        vr.thisTrialUnexpected  = 0;
        vr.thisTrialUnexpectedY = NaN;
    end
end
