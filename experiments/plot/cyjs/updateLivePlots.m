function vr = updateLivePlots(vr)
    % Update online behavioral metric plots
    behavData = vr.behaviorData(:,1:vr.trialIterations);
    figure(vr.livePlotFig);
    rew_delay_start_ix = find(behavData(8,:) == -1,1); 
    x = behavData(5,1:rew_delay_start_ix);
    y = behavData(6,1:rew_delay_start_ix);
    t = cumsum(behavData(10,:));
    rew_delay_start = t(rew_delay_start_ix);
    ITI_start = t(find(behavData(8,:) == 1,1));
    lick_trace = behavData(7,:);
    %     [lick_v,lick_ix] = findpeaks(lick_trace,'minPeakHeight',vr.livePlot_opt.minLickV);
    lick_ix = find(lick_trace >= vr.livePlot_opt.lickV);
    lick_y = y(lick_ix(lick_ix < length(y))); % y does not extend into the ITI
    lick_t = t(lick_ix); 
    lick_t_ITI = t(lick_ix(lick_ix >= rew_delay_start_ix)) - rew_delay_start; 
    lick_v = lick_trace(lick_ix); 
    n_licks = length(lick_y); % note that this ends at trial end 
    n_licks_ITI = length(lick_t_ITI); 
    
    % add to reward consumed count if rewarded and we see some lick signal
    if ~isempty(find(behavData(9,:) == 1,1)) && (n_licks + n_licks_ITI > 0)
       vr.numRewards_consumed = vr.numRewards_consumed + 1;  
    end
    
    if strcmp(vr.exper_name,'dynSwitching_CYJS')
        this_tt = 1 + (1 - vr.Rewards(end)) + 2 * strcmp(vr.pastCorrect(end),"R") + 4 * vr.Checker_trial(end); % separate by correct, choice, and checker
        vr.trial_world_lickY = [vr.trial_world_lickY ; ...
            ones(n_licks,1) + vr.numTrials zeros(n_licks,1) + this_tt lick_y'];
        vr.trial_world_ITIlickT = [vr.trial_world_ITIlickT ; ...
            ones(n_licks_ITI,1) + vr.numTrials zeros(n_licks_ITI,1) + this_tt lick_t_ITI'];
    elseif strcmp(vr.exper_name,'linearTrack_RectangeMiddle_CYJS')
        vr.trial_world_lickY = [vr.trial_world_lickY ; ...
            ones(n_licks,1) + vr.numTrials zeros(n_licks,1) + vr.currentWorld lick_y'];
        vr.trial_world_ITIlickT = [vr.trial_world_ITIlickT ; ...
            ones(n_licks_ITI,1) + vr.numTrials zeros(n_licks_ITI,1) + vr.currentWorld lick_t_ITI'];
    end
%     rew_time = t(behavData(9,:) == 1); 
    
    % Lick trace from last trial
    subplot(2,2,1);cla
    plot(t,lick_trace,'color',[.2,.8,.2],'linewidth',1); % lick signal
    scatter(lick_t,lick_v,10,[0,0,0]); % estimated lick event signals
    % add patches to indicate trial interval
    try
        v_ISI = [0 -1; 0 0; rew_delay_start 0; rew_delay_start -1];
        v_delay = [rew_delay_start -1; rew_delay_start 0; ITI_start 0; ITI_start -1]; 
        v_ITI = [ITI_start -1; ITI_start 0; t(end) 0; t(end) -1]; 
        patch('Faces',[1 2 3 4],'Vertices',v_ISI,'FaceColor',[1 1 1]);
        patch('Faces',[1 2 3 4],'Vertices',v_delay,'FaceColor',[.5 .5 .5],'FaceAlpha',.5);
        patch('Faces',[1 2 3 4],'Vertices',v_ITI,'FaceColor',[.2 .2 .2],'FaceAlpha',.5);
    catch 
        fprintf("\n Error in drawing trial period patches \n")
        disp(rew_delay_start)
        disp(ITI_start)
    end
    ylim([-1 5]); 
    title(sprintf("Trial %i Lick Behavior",vr.numTrials+1))

    % Lick raster colored by trial type
    subplot(8,8,[33:35 41:43 49:51 57:59]); cla;hold on
    custom_gscatter(vr.trial_world_lickY(:,3),vr.trial_world_lickY(:,1),vr.trial_world_lickY(:,2),vr.livePlot_opt.worldColors,vr.livePlot_opt.worldSymbols,3);
    set(gca, 'YDir','reverse')
    ylim([0 max(vr.livePlot_opt.initRasterMaxTrials,vr.numTrials)])
    subplot(8,8,[36 44 52 60]); cla
    custom_gscatter(vr.trial_world_ITIlickT(:,3),vr.trial_world_ITIlickT(:,1),vr.trial_world_ITIlickT(:,2),vr.livePlot_opt.worldColors,vr.livePlot_opt.worldSymbols,3);
    set(gca, 'YDir','reverse')
    ylim([0 max(vr.livePlot_opt.initRasterMaxTrials,vr.numTrials)])
    
    % Plot position traces colored by trial type
    vr = fading_runningTraj_livePlot(vr); 
    
    if strcmp(vr.exper_name,'dynSwitching_CYJS')
        figure(vr.performanceFig);
        subplot(1,3,1)
        cla; hold on;
        plot(smoothdata(vr.Rewards,'gaussian',15),'k','linewidth',1.5);
        subplot(1,3,2)
        cla; hold on;
        rewards_L = vr.Rewards; 
        rewards_L(vr.pastCorrect == "R") = nan; 
        rewards_R = vr.Rewards; 
        rewards_R(vr.pastCorrect == "L") = nan; 
        plot(smoothdata(rewards_L,'gaussian',15),'b','linewidth',1);
        plot(smoothdata(rewards_R,'gaussian',15),'r','linewidth',1);
        legend("L World","R World",'AutoUpdate','off');
        subplot(1,3,3)
        cla; hold on;
        rewards_checker = vr.Rewards; 
        rewards_checker(vr.Checker_trial == 0) = nan; 
        rewards_noChecker = vr.Rewards; 
        rewards_noChecker(vr.Checker_trial == 1) = nan;
        plot(smoothdata(rewards_checker,'gaussian',15),'k:','linewidth',1);
        plot(smoothdata(rewards_noChecker,'gaussian',15),'k-','linewidth',1);
        legend("Checker","NoChecker",'AutoUpdate','off');
        
        for i_subplot = 1:3
            subplot(1,3,i_subplot)
            xlim([0 max(vr.livePlot_opt.initRasterMaxTrials,vr.numTrials)])
            ylim([0 1])
            yline(.5,'--');
            if ~isempty(vr.switches)
                xline(vr.switches); 
            end
        end
        figure(vr.livePlotFig);
    end
end

