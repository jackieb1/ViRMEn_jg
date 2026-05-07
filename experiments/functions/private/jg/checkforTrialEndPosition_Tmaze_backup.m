function [vr] = checkforTrialEndPosition_Tmaze(vr)
% check for trial-terminating position and deliver reward
%if vr.inITI == 0 && (vr.position(2) > vr.mazeLength +vr.bufferWidth + vr.cueLength) && (abs(vr.position(1))>4*vr.floorWidth)
if vr.inITI == 0 && (abs(vr.position(1))>4*vr.floorWidth)
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
        if mod(vr.currentWorld,2)==1 && vr.position(1)<0
            vr.isCorrect=1;
            vr = giveReward(vr,1);
            vr.behaviorData(9,vr.trialIterations) = 1;
            vr.numRewards = vr.numRewards + 1;
            disp('Correct left turn trial');
            vr.itiDur = vr.itiCorrect;
            vr = endVRTrial(vr);
        elseif mod(vr.currentWorld,2)==0 && vr.position(1)>0
            vr.isCorrect=1;
            vr = giveReward(vr,1);
            vr.behaviorData(9,vr.trialIterations) = 1;
            vr.numRewards = vr.numRewards + 1;
            disp('Correct right turn trial');
            vr.itiDur = vr.itiCorrect;
            vr = endVRTrial(vr);
        else
            vr.isCorrect=0;
            if mod(vr.currentWorld,2)==0
                disp('Incorrect right turn trial');
            else
                disp('Incorrect left turn trial');
            end
            vr.behaviorData(9,vr.trialIterations) = 0;
            vr.itiDur = vr.itiMiss;
            vr = endVRTrial(vr);
        end
    else
        vr.behaviorData(9,vr.trialIterations) = 0;
        vr.behaviorData(8,vr.trialIterations) = -1;
    end
else
    vr.behaviorData(9,vr.trialIterations) = 0; 
end
end

