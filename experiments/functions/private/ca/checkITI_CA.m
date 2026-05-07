function vr = checkITI_CA(vr)

% check whether ITI has elapsed and if so, start a new trial

if vr.inITI == 1
    
    vr.itiTime = toc(vr.itiStartTime);

    if vr.itiTime > vr.itiDur

        % increase numtrials counter
        vr.numTrials = vr.numTrials + 1;
        %save trial data
        vr = saveTrialData(vr);

        % set up next trial:
        % check whether switch should be introduced
<<<<<<< HEAD
=======
        % vr = checkSwitch_Condition(vr); % used in PhotoStim experiments
        vr = dynamicSwitching_new_CA(vr);
>>>>>>> 0faee688483f22c3d39470c123620582a5fac97c
        
        % update block
        vr.blockWorlds = vr.contingentBlocks(vr.switchBlock,:);
        % change to noChecker maze & angled maze probabilistically
        rand_checker = rand;
        rand_grating = rand;
        if rand_checker < vr.fractionNoChecker
            vr.blockWorlds = vr.blockWorlds + 4;
        end
        if rand_grating < vr.fractionAngledGrating
            vr.blockWorlds = vr.blockWorlds +  8;
        end

        vr = chooseNextWorld_CA(vr);
        vr.inITI = 0;

        vr.position = vr.worlds{vr.currentWorld}.startLocation;
        vr.worlds{vr.currentWorld}.surface.visible(:) = 1;
        vr.worlds{vr.currentWorld}.backgroundColor = [vr.backgroundR_val vr.backgroundG_val vr.backgroundB_val];
        vr.dp = 0;
        vr.inRewardZone = 0;
        vr.trialTimer = tic;
        vr.trialStartTime = rem(now,1);
    end
    
end

end