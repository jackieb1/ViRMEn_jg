function printSessionStats_wideLinearTrack(vr)

header = fprintf('Trials \tRewards \tTime (min) \tTrials/min \tRewards/min\tFraction Right \tAccuracy \tReward Size (ul)\n');
sessionTime = toc(vr.sessionStartTime)/60;
trialsPerMin = vr.numTrials / sessionTime;
rewardsPerMin = vr.numRewards / sessionTime;
rightBias = 0;
accuracy = mean(vr.correctTrials);
rewardSize = vr.rewardSize;
stats = fprintf('%d\t%d\t%0.1f\t%0.1f\t%0.1f\t%0.2f\t%0.2f\t%s\n', vr.numTrials, vr.numRewards, sessionTime, trialsPerMin, rewardsPerMin, rightBias, accuracy, rewardSize);