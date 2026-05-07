function vr = dynamicSwitching_new_CA(vr)

% updated: numTrials does not represent index of current trial, but of
% completed trials -> adjust criterion checking

% check if conditions are met to introduce a switch:
% 1) minBlockSize: minimum number of trials since last switch
% 2) minWindow, minFraction correct: last X trials need a minimum of Y percent correct 
% 3) last trial was correct

if isempty(vr.Switches) == 1
    switches2use = 0;
else
    switches2use = vr.Switches; 
end

if (vr.numTrials + 1) - switches2use(end) > vr.minBlockSize % condition 1) % check current trial
    window2check = (vr.numTrials - vr.minWindow_4Switch) : vr.numTrials;
    if sum(vr.Rewards(window2check))/numel(window2check) >= vr.minFrac_Corr_4Switch  % condition 2)
        if vr.Rewards(vr.numTrials) == 1 % condition 3)
        % choose the other block from the current one
            if vr.switchBlock == 1
                vr.switchBlock = 2;
            elseif vr.switchBlock == 2
                vr.switchBlock = 1;
            end
            vr.Switches = [vr.Switches vr.numTrials + 1]; % append the switches vector
        end
    end
end

end