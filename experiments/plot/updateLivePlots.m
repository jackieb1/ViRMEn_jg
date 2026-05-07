function vr = updateLivePlots(vr)
    % Update online behavioral metric plots
    smooth_window = 20;
    colors = {'red', 'blue', 'magenta', 'cyan'};
    figure(vr.performanceFig);

    % Overall performance plot
    subplot(vr.livePlot_opt.nRows,vr.livePlot_opt.nSubplots,1)
    cla; hold on;
    correct = vr.correctTrials;
    correct = correct(vr.turnSide ~= "T");
    plot(smoothdata(correct,'gaussian',smooth_window),'k','linewidth',1.5);
    xlim([0 max(vr.livePlot_opt.minTrials, vr.numTrials)])

    % L/R performance plot
    subplot(vr.livePlot_opt.nRows,vr.livePlot_opt.nSubplots,2)
    cla; hold on;
    correct_L = vr.correctTrials;
    correct_L = correct_L((vr.rewardedSide=="L")&(vr.turnSide~="T"));
    if isempty(correct_L)
        correct_L = [0];
    end
    plot(smoothdata(correct_L,'gaussian',smooth_window), colors{2}, 'linewidth',1);
    
    correct_R = vr.correctTrials;
    correct_R = correct_R((vr.rewardedSide == "R")&(vr.turnSide~="T"));
    if isempty(correct_R)
        correct_R = [0];
    end
    plot(smoothdata(correct_R,'gaussian',smooth_window), colors{1}, 'linewidth',1);
    legend("L", "R", 'AutoUpdate','off','Location','southeast');
    xlim([0, max([vr.livePlot_opt.minTrials length(correct_L) length(correct_R)])]);

    % Performance by World
    subplot(vr.livePlot_opt.nRows,vr.livePlot_opt.nSubplots,3)
    cla; hold on;
    xmax = vr.livePlot_opt.minTrials;
    for i = 1:vr.nWorlds
        correct_worldi = vr.correctTrials;
        correct_worldi = correct_worldi((vr.worldTrials == i)&(vr.turnSide~="T"));
        xmax = max(xmax, length(correct_worldi));
        if isempty(correct_worldi)
            correct_worldi = [0];
        end           
%         correct(vr.worldTrials == i) = nan;
        plot(smoothdata(correct_worldi,'gaussian',smooth_window), colors{i}, 'linewidth',1);
    end
    
    if vr.nWorlds == 2
        labels = ["R", "L"];
    else
        labels = ["R", "L", "R2", "L2"];
    end
    legend(labels, 'AutoUpdate','off','Location','southeast');
    xlim([0 xmax]);
    
    % Trial time by World
    subplot(vr.livePlot_opt.nRows,vr.livePlot_opt.nSubplots,4)
    cla; hold on;
    xmax = vr.livePlot_opt.minTrials;
    for i = 1:vr.nWorlds
        time_worldi = vr.trialTimeTrials;
        time_worldi = time_worldi(vr.worldTrials == i);
        xmax = max(xmax, length(time_worldi));
        if isempty(time_worldi)
            time_worldi = [0];
        end           
%         correct(vr.worldTrials == i) = nan;
        plot(smoothdata(time_worldi,'gaussian',smooth_window), colors{i}, 'linewidth',1);
    end
    
    if vr.nWorlds == 2
        labels = ["R", "L"];
    else
        labels = ["R", "L", "R2", "L2"];
    end
    legend(labels, 'AutoUpdate','off','Location','southeast');
    xlim([0 xmax]);

    % Time per trial
    subplot(vr.livePlot_opt.nRows,vr.livePlot_opt.nSubplots,5)
    cla; hold on;
    bar(1:vr.numTrials, vr.trialTimeTrials, 'FaceColor', 'black')

    for i_subplot = 1:vr.livePlot_opt.nSubplots
        subplot(1,vr.livePlot_opt.nSubplots,i_subplot)
        xlim([0 max(vr.livePlot_opt.minTrials, vr.numTrials)])
        if i_subplot < 4
            ylim([0 1])
            yline(.5,'--');
        end
        
    end


    for i_subplot = 1:vr.livePlot_opt.nSubplots
        subplot(vr.livePlot_opt.nRows,vr.livePlot_opt.nSubplots,i_subplot)
        xlim([0 max(vr.livePlot_opt.minTrials, vr.numTrials)])
        if i_subplot < 4
            ylim([0 1])
            yline(.5,'--');
        end

    end

    
    % Performance stats
    subplot(vr.livePlot_opt.nRows, vr.livePlot_opt.nSubplots, 6)
    cla; hold on;
    sessionTime_min = toc(vr.sessionStartTime)/60;
    text(0, 0, ['Time: ' num2str(sessionTime_min) ' min'])
    text(0, -1, ['Trials: ' num2str(vr.numTrials)])
    text(0, -2, ['Rewards: ' num2str(vr.numRewards)])
    text(0, -3, ['Trials/min: ' num2str(vr.numTrials/sessionTime_min)])
    text(0, -4, ['Rewards/min: ' num2str(vr.numRewards/sessionTime_min)])
    turnSide = vr.turnSide;
    turnSide = turnSide(vr.turnSide ~= "T");
    text(0, -5, ['% Right: ' num2str(mean(turnSide=="R")*100)])
    correct = vr.correctTrials;
    correct = correct(vr.turnSide ~= "T");
    text(0, -6, ['% Correct: ' num2str(mean(correct)*100)])
end

