function vr = checkForDarkWorldRunningRew(vr)
% virmen runs at 60Hz on average (60 iter / s)
% if we want to give 300 rewards in 20 min, minIterBetweenRew is 100 iters,
% reward prob should be about 0.4
% disp(vr.velocity(1))
% check forward velocity and iter since last rew exceeds minimal value
if (-vr.velocity(1) > vr.runningThres) && (vr.iterSinceLastRew > vr.minIterBetweenRew)
    % randomly generate a number between 1 and 1000 for comparison
    random_comp = randi(1000); 
    if (random_comp/1000)<= vr.rewardProb
        % give reward and store reward time
        vr.behaviorData(9,vr.trialIterations) = 1;
        vr.numRewards = vr.numRewards + 1;
        vr = giveReward(vr,1);
        vr.iterSinceLastRew = 0; % reset after reward
        % print out reward update
        fprintf('\n Time elapsed: %s \t',datestr(now-vr.timeStarted, 'HH:MM:SS')); % print the time elapsed 
        fprintf("%i rewards received \t\n",vr.numRewards)
    end
else % no reward delivered, add one to iterSinceLastRew
    vr.iterSinceLastRew = vr.iterSinceLastRew + 1;
end
