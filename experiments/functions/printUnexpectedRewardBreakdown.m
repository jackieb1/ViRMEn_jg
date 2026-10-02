function printUnexpectedRewardBreakdown(vr)
%printUnexpectedRewardBreakdown  Summary for the unexpected-reward task.
%   Companion to printSessionStats_wideLinearTrack. Reports how many trials got an
%   unexpected reward against what was requested, and the count at each y-location.

    nTrials = numel(vr.trialUnexpected);
    fprintf('\nUnexpected reward breakdown\n');
    if nTrials == 0
        fprintf('  No completed trials.\n');
        return
    end
    isUnexp = vr.trialUnexpected == 1;
    nUnexp  = sum(isUnexp);
    fprintf('  Unexpected-reward trials : %d of %d (%.1f%%, requested %.1f%%)\n', ...
        nUnexp, nTrials, 100*nUnexp/nTrials, 100*vr.unexpectedRewardFraction);
    fprintf('  Delivered                : %d\n', sum(vr.trialUnexpectedDelivered == 1));
    for k = 1:vr.unexpectedRewardNumLocations
        y = vr.unexpectedRewardYLocations(k);
        n = sum(vr.trialUnexpectedYLocation(isUnexp) == y);
        fprintf('  y = %-6g               : %d\n', y, n);
    end
    fprintf('  Unexpected volume        : %g ul (%d x %g ul; not counted toward max volume)\n', ...
        vr.numUnexpectedRewards * vr.unexpectedRewardSizeUl, ...
        vr.numUnexpectedRewards, vr.unexpectedRewardSizeUl);
end
