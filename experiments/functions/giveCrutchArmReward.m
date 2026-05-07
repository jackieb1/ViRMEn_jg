function [vr] = giveCrutchArmReward(vr)
    % If in crutch reward zone for the first time
    inCrutchRewardZone = abs(vr.position(1)) > vr.xCrutchRewardZoneThresh;
    if (vr.numTrials > 1) && inCrutchRewardZone && (vr.enteredCrutchRewardZone == 0) && (vr.inITI==0)

        correctLeft = mod(vr.currentWorld,2)==1 && vr.position(1)<0;
        correctRight = mod(vr.currentWorld,2)==0 && vr.position(1)>0;

        window = 20;
        if correctRight || correctLeft
            if correctRight
                side = "L";
                % Note side inversion because projector is flipped
            elseif correctLeft
                side = "R";
            end
            accuracy = vr.correctTrials(vr.rewardedSide == side);
            pCrutchReward = 1 - mean(accuracy(max(1, end-window):end));
            fprintf('Entered Correct Arm. Crutch Reward Probability: %.2f.\n', pCrutchReward)
            
            % Give reward with probability = 1 - accuracy for that side
            if rand <= pCrutchReward
                disp('Giving crutch reward.')
                vr = giveReward(vr, vr.rewardsPerTrial);
                vr.behaviorData(9,vr.trialIterations) = vr.rewardsPerTrial;
                vr.numRewards = vr.numRewards + vr.rewardsPerTrial;
            else
                vr.behaviorData(9,vr.trialIterations) = 0;
            end
            
            vr.enteredCrutchRewardZone = 1;

        end

    end
end
    
