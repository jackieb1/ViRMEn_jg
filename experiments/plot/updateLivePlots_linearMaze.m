function vr = updateLivePlots_linearMaze(vr)
    figure(vr.performanceFig);

    % Time per trial
    subplot(vr.livePlot_opt.nRows,vr.livePlot_opt.nSubplots, 1)
    cla; hold on;
    bar(1:vr.numTrials, vr.trialTimeTrials, 'FaceColor', 'black')

    for i_subplot = 1:vr.livePlot_opt.nSubplots-1
        subplot(1,vr.livePlot_opt.nSubplots,i_subplot)
        xlim([0 max(vr.livePlot_opt.minTrials, vr.numTrials)])
    end

    % Performance stats
    subplot(vr.livePlot_opt.nRows, vr.livePlot_opt.nSubplots, 2)
    cla; hold on;
    sessionTime_min = toc(vr.sessionStartTime)/60;
    text(0, 0, ['Time: ' num2str(sessionTime_min) ' min'])
    text(0, -1, ['Trials: ' num2str(vr.numTrials)])
    text(0, -2, ['Rewards: ' num2str(vr.numRewards)])
    text(0, -3, ['Trials/min: ' num2str(vr.numTrials/sessionTime_min)])
    text(0, -4, ['Rewards/min: ' num2str(vr.numRewards/sessionTime_min)])
%     set(gca,'visible','off')
end

