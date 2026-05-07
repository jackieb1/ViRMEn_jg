function vr = checkSwitch_Condition(vr)

% check if conditions are met to introduce a block switch, either because:
% a) Photostimulation block is over, or
% b) switch conditions are met


% vr.PhotoStimBlock = false; % indicating whether we are in a Photostim
% block or not, initialized as false at Virmen start


% check a) if we are one trial after last trial of Photoinhibition block, if a
% block exists already
if isempty(vr.ind_trials2inhibit) == 0
    if vr.numTrials + 1 == vr.Switches(end) + vr.inhibBlock_size + 1
        
        % stop PhotoStim block
        vr.PhotoStimBlock = false;
        % reset indices of trials for photoinhibition
        vr.ind_trials2inhibit = [];
        
        % change the rule
        vr.RuleSwitches = [vr.RuleSwitches vr.numTrials+1];
        
         if vr.switchBlock == 1  % choose the other block from the current one
            vr.switchBlock = 2;
        elseif vr.switchBlock == 2
            vr.switchBlock = 1;
         end
         vr.Switches = [vr.Switches vr.numTrials+1]; % append the switches vector
    end
end
        

% switch conditions
% 1) minBlockSize: minimum number of trials since last switch
% 2) minWindow, minFraction correct: last X trials need a minimum of Y percent correct 
% 3) last trial was correct

if isempty(vr.Switches) == 1
    switches2use = 0;
else
    switches2use = vr.Switches;
end

% check b) switch conditions
if vr.numTrials - switches2use(end) > vr.minBlockSize % condition 1) % check current trial
    window2check = (vr.numTrials - vr.minWindow_4Switch) : vr.numTrials;
    if sum(vr.Rewards(window2check))/numel(window2check) >= vr.minFrac_Corr_4Switch  % condition 2)
        if vr.Rewards(vr.numTrials) == 1 % condition 3)
            
            % now check which block we are in and alternate between
            % photostim and rule change blocks: 
            
            % change to a Photostimulation block for every other switch,
            % i.e. for switches 1,3,5,...
                        
            % change the rule (i.e. introduce an actual switch in
            % stim-reward association) only on every other switch, i.e. for
            % switches 2,4,6...
        
            if switches2use == 0 % if no switch has happened yet
                
                % change to Photostim block
                vr.PhotoStimBlock = true;
                % don't change the rule
                                
            elseif mod(numel(switches2use),2) == 1 % if number of switches up to now is odd, i.e. 1,3,5, i.e. if we are in block 2,4,6
                
                % don't change to Photostim block
                % vr.PhotoStimBlock = false; 
                
                % change the rule
                 vr.RuleSwitches = [vr.RuleSwitches vr.numTrials+1];
                 if vr.switchBlock == 1  % choose the other block from the current one
                    vr.switchBlock = 2;
                elseif vr.switchBlock == 2
                    vr.switchBlock = 1;
                 end
            
            else % if number of switches up to now is even, i.e. 2,4, i.e. we are in block 3,5,...
                
                % (don't change the rule)
      
                % start Photostim block
                vr.PhotoStimBlock = true;
            end
            
            % in all cases, append the switch vector
            vr.Switches = [vr.Switches vr.numTrials+1]; % append the switches vector
        end
    end
end

end