function vr = updateLivePlots_wideLinearTrack(vr)
    figure(vr.performanceFig);
    smooth_window = 20;
    
    % Overall performance plot
    subplot(vr.livePlot_opt.nRows,vr.livePlot_opt.nSubplots,1)
    cla; hold on;
    plot(smoothdata(vr.correctTrials,'gaussian',smooth_window),'k','linewidth',1.5);
    xlim([0 max(vr.livePlot_opt.minTrials, vr.numTrials)])

    % Time per trial
    subplot(vr.livePlot_opt.nRows,vr.livePlot_opt.nSubplots, 2)
    cla; hold on;
    bar(1:vr.numTrials, vr.trialTimeTrials, 'FaceColor', 'black')

    for i_subplot = 1:vr.livePlot_opt.nSubplots-1
        subplot(1,vr.livePlot_opt.nSubplots,i_subplot)
        xlim([0 max(vr.livePlot_opt.minTrials, vr.numTrials)])
    end

    % Performance stats
    subplot(vr.livePlot_opt.nRows, vr.livePlot_opt.nSubplots, 3)
    cla; hold on;
    sessionTime_min = toc(vr.sessionStartTime)/60;
    text(0, 0, ['Time: ' num2str(sessionTime_min) ' min'])
    text(0, -1, ['Trials: ' num2str(vr.numTrials)])
    text(0, -2, ['Rewards: ' num2str(vr.numRewards)])
    text(0, -3, ['Trials/min: ' num2str(vr.numTrials/sessionTime_min)])
    text(0, -4, ['Rewards/min: ' num2str(vr.numRewards/sessionTime_min)])
    text(0, -5, ['% Correct: ' num2str(mean(vr.correctTrials)*100)])
    recentWindow = 20;
    recent = vr.correctTrials(max(1, numel(vr.correctTrials)-recentWindow+1):end);
    text(0, -6, ['% Correct - recent: ' num2str(mean(recent)*100)])

    % Omission / variable-size reward task only. writePerformanceToExcel ignores any
    % 'Label: value' line whose label is not in its statToHeader map, so these are
    % displayed but not written to the tracking spreadsheet.
    if isfield(vr, 'numOmissions')
        ylim([-9 1]);   % init set [-7 1]; make room for the two extra lines
        done  = vr.trialRewardSize(~isnan(vr.trialRewardSize));   % trials that reached the tower
        nDone = numel(done);
        nOmit = sum(done == 0);
        if nDone > 0
            pctOmit = 100 * nOmit / nDone;
        else
            pctOmit = 0;
        end
        text(0, -7, sprintf('Omissions: %d (%.1f%%)', nOmit, pctOmit))
        sizeStr = '';
        for k = 1:numel(vr.rewardSizeValues)
            sizeStr = [sizeStr sprintf('%gul:%d ', ...
                vr.rewardSizeValues(k), sum(done == vr.rewardSizeValues(k)))]; %#ok<AGROW>
        end
        text(0, -8, sprintf('%s| %g/%g ul', sizeStr, vr.totalRewardVolume, vr.maxRewardVolume))
    end

    % Unexpected-reward task only. "Rewards" above counts tower/manual rewards only;
    % unexpected rewards are listed separately here. Like the omission lines, these
    % labels are not in writePerformanceToExcel's map, so they are display-only.
    if isfield(vr, 'numUnexpectedRewards')
        yNext = -7;
        if isfield(vr, 'numOmissions'), yNext = -9; end   % below the omission lines
        ylim([yNext-2 1]);
        nT = numel(vr.trialUnexpected);
        if nT > 0
            pctUnexp = 100 * sum(vr.trialUnexpected == 1) / nT;
        else
            pctUnexp = 0;
        end
        text(0, yNext, sprintf('Unexpected rew: %d (%.1f%% of trials)', ...
            vr.numUnexpectedRewards, pctUnexp))
        locStr = '';
        for k = 1:vr.unexpectedRewardNumLocations
            y = vr.unexpectedRewardYLocations(k);
            locStr = [locStr sprintf('y%g:%d ', y, ...
                sum(vr.trialUnexpectedYLocation(vr.trialUnexpectedDelivered == 1) == y))]; %#ok<AGROW>
        end
        text(0, yNext-1, strtrim(locStr))
    end
%     set(gca,'visible','off')
end

