function vr = checkPhotostim_Condition_OLD(vr)

% checks whether conditions for photostim trigggering are met and if so,
% triggers Photostim PC

% photostim should be triggered if: 
% 1) current trial is in Photostim block
% 2) current trial is chosen as a photostim trial probabilistically
% 3) current segment of current trial (e.g. stimulus or feedback period) is
% to be stimulated in

% ////same code as in dynamicSwitching_CA.m file (1st half, checking
% condition for switching)
if isempty(vr.Switches) == 1 % 
    switches2use = 0;
else
    switches2use = vr.Switches;
end

if vr.numTrials - switches2use(end) > vr.minBlockSize % condition 1 for switching)
    window2check = (vr.numTrials - vr.minWindow_4Switch) : vr.numTrials;
    if sum(vr.Rewards(window2check))/numel(window2check) >= vr.minFrac_Corr_4Switch  % condition 2 for switching)
        if vr.Rewards(vr.numTrials-1) == 1 % condition 3 for switching) 
            % ////////////////
            
            %if all conditions for switching are met, check conditions for photostimulation 
        
            if (vr.numTrials - switches2use(end) > vr.minBlockSize) || (vr.numTrials < switches2use(end) + vr.inhibBlock_size) % (condition 1)
    
                if isempty(vr.ind_trials2inhibit) % if no trials have been selected for inhibition
                    % generate vector of random trials indices to inhibit
                    block2use = vr.numTrials:(vr.numTrials + vr.inhibBlock_size); % block of trials to draw randomly from
                    vr.ind_trials2inhibit = randsample(block2use,numel(block2use)*vr.frac_inhibTrials);
                end
    
                if ismember(vr.numTrials, vr.ind_trials2inhibit) % check if current trial is in vector of trials to inhibit on (condition 2)
        
                    if vr.segment_inhib == 'stimulus' % if the segment to inhibit in is the 'stimulus' condition, i.e. when visual cues are present
                        
                        if vr.position(2) <= (vr.floorLength + vr.funnelLength) % if mouse is part of maze with visual stimuli on wall (condition 3)
                
                            vr = triggerPhotoStimPC(vr, 1); % set digital line to Photostim PC to 1 (i.e. trigger photostimulation)
                            disp('Photostim')
                        else
                            vr = triggerPhotoStimPC(vr, 0); % set digital line to Photostim PC to 0
                        end
                        
                    elseif vr.segment_inhib == 'feedback'  % if the segment to inhibit in is the 'feedback' condition
                        
                        % check if mouse is past maze end or if mouse is in ITI period
                        if vr.position(2) >= vr.rewardLength || vr.ITI == 1
                            
                            vr = triggerPhotoStimPC(vr,1);
                            disp('Photostim')
                        else
                            vr = triggerPhotostimPC(vr,0);
                        end
                    end
                    
                else 
                    vr = triggerPhotoStimPC(vr, 0);
                end
            else
                vr = triggerPhotoStimPC(vr, 0);
            end
        else
            vr = triggerPhotoStimPC(vr, 0);
        end
    else
        vr = triggerPhotoStimPC(vr, 0);
    end

end