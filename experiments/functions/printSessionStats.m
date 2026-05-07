function printSessionStats(vr)

header = fprintf('Trials \tRewards \tTime (min) \tTrials/min \tRewards/min\tFraction Right \tAccuracy \tReward Size (ul)\n');
sessionTime = toc(vr.sessionStartTime)/60;
trialsPerMin = vr.numTrials / sessionTime;
rewardsPerMin = vr.numRewards / sessionTime;
turnSide = vr.turnSide;
turnSide = turnSide(vr.turnSide ~= "T");
rightBias = mean(turnSide=="R"); % right bias because mazes are flipped
correct = vr.correctTrials;
correct = correct(vr.turnSide ~= "T");
accuracy = mean(correct);
stats = fprintf('%d\t%d\t%0.1f\t%0.1f\t%0.1f\t%0.2f\t%0.2f\t%s\n', vr.numTrials, vr.numRewards, sessionTime, trialsPerMin, rewardsPerMin, rightBias, accuracy, vr.rewardSize);