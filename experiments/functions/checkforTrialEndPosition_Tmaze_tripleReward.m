function [vr] = checkforTrialEndPosition_Tmaze_tripleReward(vr)
% check for trial-terminating position and deliver reward
%if vr.inITI == 0 && (vr.position(2) > vr.mazeLength +vr.bufferWidth + vr.cueLength) && (abs(vr.position(1))>4*vr.floorWidth)
if (vr.inITI==0) && (abs(vr.position(1))>vr.xRewardZoneThresh) && (vr.position(2) > vr.cueLength+vr.floorLength)
    % check if mouse is in reward zone mediolaterally, if 
    % Disable movement
    vr.dp = 0*vr.dp;
    % Enforce Reward Delay
    if ~vr.inRewardZone
        vr.rewStartTime = tic;
        vr.inRewardZone = 1;
    end
    vr.rewDelayTime = toc(vr.rewStartTime);    
    if vr.rewDelayTime > vr.rewardDelay
        % Log turn side
        if vr.position(1)<0
            % Inverted because of flipped screen
            vr.turnSide = [vr.turnSide "R"];
        else
            vr.turnSide = [vr.turnSide "L"];
        end
        
        % Log rewarded side
        if mod(vr.currentWorld,2)==1
            % Note inverse from above because maze is flipped on screen
            vr.rewardedSide = [vr.rewardedSide "R"];
        else
            vr.rewardedSide = [vr.rewardedSide "L"];
        end
        
        correctLeft = mod(vr.currentWorld,2)==1 && vr.position(1)<0;
        correctRight = mod(vr.currentWorld,2)==0 && vr.position(1)>0;
        if correctLeft || correctRight
            vr.isCorrect = 1;
            vr = giveRecordProbReward(vr, vr.correctRewardProbability(vr.currentWorld));
            vr = giveRecordProbReward(vr, vr.correctRewardProbability(vr.currentWorld));
            vr = giveRecordProbReward(vr, vr.correctRewardProbability(vr.currentWorld));
            if correctLeft
                disp('Correct left turn trial');
            else
                disp('Correct right turn trial');
            end
            vr.itiDur = vr.itiCorrect;
        else
            vr.isCorrect = 0;
            vr = giveRecordProbReward(vr, vr.incorrectRewardProbability(vr.currentWorld));
            vr = giveRecordProbReward(vr, vr.incorrectRewardProbability(vr.currentWorld));
            incorrectRight = mod(vr.currentWorld,2)==0;
            if incorrectRight
                disp('Incorrect right turn trial');
            else
                disp('Incorrect left turn trial');
            end
            vr.itiDur = vr.itiMiss;
        end
        vr = endTrialTMaze(vr);
    else
        vr.behaviorData(9,vr.trialIterations) = 0;
        vr.behaviorData(8,vr.trialIterations) = -1;
    end
else
    vr.behaviorData(9,vr.trialIterations) = 0; 
end
end

