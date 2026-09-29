function printRewardBreakdown(vr)
%printRewardBreakdown  Per-size / omission summary for the variable-size reward task.
%   Companion to printSessionStats_wideLinearTrack. Reports what was actually
%   delivered against what was requested, counting only trials on which the animal
%   reached the reward zone (vr.trialRewardSize is NaN on the rest).

    done  = vr.trialRewardSize(~isnan(vr.trialRewardSize));
    nDone = numel(done);
    fprintf('\nReward breakdown\n');
    if nDone == 0
        fprintf('  No completed reward-zone entries.\n');
        return
    end
    nOmit = sum(done == 0);
    nRew  = nDone - nOmit;
    fprintf('  Reward-zone entries : %d\n', nDone);
    fprintf('  Omissions           : %d (%.1f%%, requested %.1f%%)\n', ...
        nOmit, 100*nOmit/nDone, 100*vr.rewardOmissionFraction);
    for k = 1:numel(vr.rewardSizeValues)
        n = sum(done == vr.rewardSizeValues(k));
        if nRew > 0
            fprintf('  %-5g ul            : %d (%.1f%% of rewarded, requested %.1f%%)\n', ...
                vr.rewardSizeValues(k), n, 100*n/nRew, 100*vr.rewardSizeProbs(k));
        else
            fprintf('  %-5g ul            : %d\n', vr.rewardSizeValues(k), n);
        end
    end
    fprintf('  Total volume        : %g / %g ul\n', vr.totalRewardVolume, vr.maxRewardVolume);
end
