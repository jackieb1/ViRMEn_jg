function vr = checkPhotostim_Condition_new(vr)

% checks whether conditions for photostim trigggering are met and if so,
% triggers Photostim PC

% photostim should be triggered if: 
% 1) current trial is in Photostim block
% 2) current trial is chosen as a photostim trial probabilistically
% 3) current segment of current trial (e.g. stimulus or feedback period) is
% to be stimulated in

switches2use = vr.Switches;

if vr.PhotoStimBlock == true % if we are in Photostim block (condition 1)
    
    if isempty(vr.ind_trials2inhibit) % if no trials have been selected for inhibition
        % generate vector of random trials indices to inhibit
        
        % numTrials indicates number of completed trials, so add 1 for
        % current trial
        
        block2use = vr.numTrials+1:(vr.numTrials+1 + vr.inhibBlock_size); % block of trials to draw randomly from
        vr.ind_trials2inhibit = randsample(block2use,numel(block2use)*vr.frac_inhibTrials);
    end
                    
    %if vr.numTrials < (switches2use(end) + vr.inhibBlock_size) % (condition 1)

        if ismember(vr.numTrials+1, vr.ind_trials2inhibit) % check if current trial is in vector of trials to inhibit on (condition 2)
            % numTrials indicates number of completed trials, so add 1 to
            % get current trial
            
            % assert that vr.segment_inhib is either 'stimulus' or 'stim',
            % otherwise give a specific error
            toassert =  ~isempty( find(strcmp(vr.segment_inhib,{'stimulus', 'feedback'})) ); % checks whether string is one of the 2 desired ones
            assert(toassert, 'Segment to inhibit is not specified correctly (either stimulus or feedback)');
            
            if vr.segment_inhib == 1 % if the segment to inhibit in is the 'stimulus' condition, i.e. when visual cues are present

                if vr.position(2) <= (vr.floorLength + vr.funnelLength) % if mouse is in part of maze with visual stimuli on wall (condition 3)
                    
                    vr.PhotoStimInfo = 1;
                    vr = triggerPhotoStimPC(vr, 1); % set digital line to Photostim PC to 1 (i.e. trigger photostimulation)
                    disp('Photostim')
                else
                    vr.PhotoStimInfo = 0;
                    vr = triggerPhotoStimPC(vr, 0); % set digital line to Photostim PC to 0
                end

            elseif vr.segment_inhib == 2  % if the segment to inhibit in is the 'feedback' condition

                % check if mouse is past maze end or if mouse is in ITI period
                if vr.position(2) >= vr.rewardLength || vr.inITI == 1
                    
                    vr.PhotostimInfo = 1;
                    vr = triggerPhotoStimPC(vr,1);
                    disp('Photostim')
                else
                    vr.PhotoStimInfo = 0;
                    vr = triggerPhotoStimPC(vr,0);
                end
            end

        else 
            vr.PhotoStimInfo = 0;
            vr = triggerPhotoStimPC(vr, 0);
        end
    else
        vr.PhotoStimInfo = 0;
        vr = triggerPhotoStimPC(vr, 0);
end
% else
%     vr.PhotoStimInfo = 0;
%     vr = triggerPhotoStimPC(vr, 0);
end

