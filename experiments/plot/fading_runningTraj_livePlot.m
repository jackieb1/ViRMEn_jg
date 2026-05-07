function vr = fading_runningTraj_livePlot(vr)
%% Plot position trajectories color-coded by trial type, fading over time
    behavData = vr.behaviorData(:,1:vr.trialIterations);
    rew_delay_start_ix = find(behavData(8,:) == -1,1); 
    x = behavData(5,1:rew_delay_start_ix);
    y = behavData(6,1:rew_delay_start_ix);
    this_world = vr.currentWorld;

    if strcmp(vr.exper_name,'dynSwitching_CYJS')
        % update live_saved_xy
        if ~isempty(vr.switches) 
           if vr.switches(end) == vr.numTrials 
               % clear non-visually guided trial trajectories if we just
               % had a switch
               vr.live_saved_xy{1} = []; vr.live_saved_xy{2} = [];
           end
        end
        % Blue = nonVis LEFT, Red = nonVis RIGHT
        % Grey = Vis    LEFT, Brwn= Vis    RIGHT
        xy_save_grps = [2 4 ; 1 3 ; 6 8 ; 5 7]; 
        
        [this_xy_save_grp,~] = find(xy_save_grps == this_world); 
        % update live_saved_xy
        if numel(vr.live_saved_xy{this_xy_save_grp}) < vr.livePlot_opt.n_save_trials % append if fewer than save trials
            vr.live_saved_xy{this_xy_save_grp} = [vr.live_saved_xy{this_xy_save_grp} ; {[x' y']}];
        else % else cirshift to pop
            vr.live_saved_xy{this_xy_save_grp} = circshift(vr.live_saved_xy{this_xy_save_grp},1);
            vr.live_saved_xy{this_xy_save_grp}{1} = [x' y'];
        end
        
        for plot_counter = [0 2] % handle visually vs non-visually guided trials
            n_trials_grp = cellfun(@length,vr.live_saved_xy);
            subplot(2,2,2 + plot_counter) 
            % now prepare the non-visually guided colormap
            new_cmap = [];
            for i_grp = ((1:2)+plot_counter)
                % this weird stuff is due to how cbrewer works
                i_grp_colors = flipud(cbrewer('seq',vr.livePlot_opt.color_gradient_order(i_grp),max(3,n_trials_grp(i_grp)),'spline'));
                i_grp_colors = min(1,i_grp_colors(end-n_trials_grp(i_grp)+1:end,:));
                new_cmap = [new_cmap ; i_grp_colors];
            end
            % update color order
            set(gca, 'ColorOrder', new_cmap, 'NextPlot', 'replacechildren');
            cla;draw_Ymaze(vr);hold on
            % plot
            for i_grp = ((1:2)+plot_counter)
                arrayfun(@(i_trial) plot(vr.live_saved_xy{i_grp}{i_trial}(:,1),vr.live_saved_xy{i_grp}{i_trial}(:,2)),(1:n_trials_grp(i_grp)));
            end
        end

        
    elseif strcmp(vr.exper_name,'linearTrack_RectangeMiddle_CYJS')
        % update live_saved_xy
        if numel(vr.live_saved_xy{this_world}) < vr.livePlot_opt.n_save_trials % append if fewer than save trials
            vr.live_saved_xy{this_world} = [vr.live_saved_xy{this_world} ; {[x' y']}];
        else % else cirshift to pop
            vr.live_saved_xy{this_world} = circshift(vr.live_saved_xy{this_world},1);
            vr.live_saved_xy{this_world}{1} = [x' y'];
        end
        
        % now prepare the colormap
        n_trials_world = cellfun(@length,vr.live_saved_xy);
        new_cmap = [];
        for i_world = 1:vr.nWorlds
            % this weird stuff is due to how cbrewer works
            i_world_colors = flipud(cbrewer('seq',vr.livePlot_opt.color_gradient_order(i_world),max(3,n_trials_world(i_world)),'spline'));
            i_world_colors = i_world_colors(end-n_trials_world(i_world)+1:end,:);
            new_cmap = [new_cmap ; i_world_colors];
        end
        % update color order
        subplot(2,2,[2 4])
        set(gca, 'ColorOrder', new_cmap, 'NextPlot', 'replacechildren');
        cla;hold on
        
        % plot
        for i_world = 1:vr.nWorlds
            arrayfun(@(i_trial) plot(vr.live_saved_xy{i_world}{i_trial}(:,1),vr.live_saved_xy{i_world}{i_trial}(:,2)),(1:n_trials_world(i_world)));
        end
    end
end

