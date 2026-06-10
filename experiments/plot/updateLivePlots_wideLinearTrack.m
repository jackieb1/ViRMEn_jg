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
%     set(gca,'visible','off')
end

