function [vr] = giveRecordVarReward(vr)
%giveRecordVarReward  Omit the reward, or deliver one of three sizes.
%   Companion to giveRecordProbReward for the omission / variable-size reward task.
%   Call once per trial when the animal enters the reward zone, after
%   getVarRewardParams has set up the draw parameters.
%
%   On an omission trial it prints 'Reward omission ##'; otherwise it prints
%   'Giving reward number ## - size ## ul' (via giveReward's optional size argument).
%
%   behaviorData rows written here:
%     row  9 : 1 = a reward pulse fired, 0 = reward omitted (unchanged meaning)
%     row 15 : reward size in ul, 0 on an omission, NaN on every other iteration

    if rand < vr.rewardOmissionFraction
        vr.numOmissions           = vr.numOmissions + 1;
        vr.thisTrialRewardSize    = 0;
        vr.thisTrialRewardOmitted = 1;
        vr.behaviorData(9,  vr.trialIterations) = 0;
        vr.behaviorData(15, vr.trialIterations) = 0;
        disp(['Reward omission ', num2str(vr.numOmissions)]);
    else
        idx    = find(rand <= cumsum(vr.rewardSizeProbs), 1, 'first');
        if isempty(idx)
            idx = numel(vr.rewardSizeProbs);   % guard against float round-off at p = 1
        end
        sizeUl = vr.rewardSizeValues(idx);

        % Incremented before giveReward so the printed reward number is 1-based and
        % lines up with the omission counter. updateLickPlot watches this rising edge
        % later in the same iteration, so its markers are unaffected.
        vr.numRewards        = vr.numRewards + 1;
        vr.totalRewardVolume = vr.totalRewardVolume + sizeUl;

        vr.thisTrialRewardSize    = sizeUl;
        vr.thisTrialRewardOmitted = 0;
        vr.behaviorData(9,  vr.trialIterations) = 1;
        vr.behaviorData(15, vr.trialIterations) = sizeUl;

        % vr.rewardSize is what giveReward looks up in ops.rewardPulseDurationDict.
        % Restore it afterwards: the engine discards the vr returned by the termination
        % code and then hands its own vr to writePerformanceToExcel, which would
        % otherwise log whichever size happened to be drawn last as the session size.
        sessionSizeKey = vr.rewardSize;
        vr.rewardSize  = vr.rewardSizeKeys{idx};
        vr = giveReward(vr, 1, sizeUl);
        vr.rewardSize  = sessionSizeKey;
    end
end
