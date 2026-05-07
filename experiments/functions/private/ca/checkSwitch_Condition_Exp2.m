function vr = checkSwitch_Condition_Exp2(vr)

% for exp 2, PhotoInhibition blocks are introduced along with switches (not
% only after stable performance has been reached)


% check if we are one trial after last trial of Photoinhibition block, if a
% block exists already
if isempty(vr.ind_trials2inhibit) == 0
    if vr.numTrials + 1 == vr.Switches(end) + vr.inhibBlock_size + 1
        
        % stop PhotoStim block
        vr.PhotoStimBlock = false;
        % reset indices of trials for photoinhibition
        vr.ind_trials2inhibit = [];
    end
end

% check if conditions are met to introduce a block switch

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
if vr.numTrials + 1 - switches2use(end) > vr.minBlockSize % condition 1) % check current trial
    window2check = (vr.numTrials - vr.minWindow_4Switch) : vr.numTrials;
    if sum(vr.Rewards(window2check))/numel(window2check) >= vr.minFrac_Corr_4Switch  % condition 2)
        if vr.Rewards(vr.numTrials) == 1 % condition 3)
            
            % change the rule
             vr.RuleSwitches = [vr.RuleSwitches vr.numTrials+1];
             if vr.switchBlock == 1  % choose the other block from the current one
                vr.switchBlock = 2;
            elseif vr.switchBlock == 2
                vr.switchBlock = 1;
             end
             
             % change to a Photostimulation block for every switch
             vr.PhotoStimBlock = true;
             % append the switch vector
             vr.Switches = [vr.Switches vr.numTrials+1]; % append the switches vector
      
        end
    end
end

end