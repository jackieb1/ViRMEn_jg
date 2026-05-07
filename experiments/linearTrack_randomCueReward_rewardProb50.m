function code = linearTrack_randomCueReward
% linearTrackNew   Code for the ViRMEn experiment linearTrackNew.
%   code = linearTrackNew   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT


%% MAZE DESCRIPTION
% Infinite linear maze (loops back on itself) with 4 wall cues and
% associated landmarks.

% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)

    % wrap world
    vr.mazeLength = eval(vr.exper.variables.mazewidth);
    vr = wrapLinearWorlds(vr);
%     vr = wrapLinearWorld(vr, 1, 1);
%     vr = wrapLinearWorld(vr, 2, 1);
    
    % Initialize VR
    vr.debugMode = false;
    vr.ops = getRigInfo();
    vr = makeVirmenDir(vr);
    vr = initLinearTrack(vr);
    vr = initDAQ(vr);
    vr = initLivePlots_linearMaze(vr);
    
    % Initialize maze
    vr.rewardLocation = 375;
    vr.cueTrialProbability = 0.4;
    vr.isCueTrial = false;
    vr.CueRevealPosition = 250;
    vr.currentWorld = 1;
    vr.rewardProbability = 0.5;
    vr.isRewardTrial = (rand <= vr.rewardProbability);
    
    
    

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % Loop maze
    if vr.position(2) > vr.mazeLength
        vr = endLinearTrackTrial(vr);
        vr = initLinearTrackTrial(vr);
        vr = updateLivePlots_linearMaze(vr);
        if rand <= vr.cueTrialProbability
            vr.isCueTrial = true;
        else
            vr.isCueTrial = false;
        end
        vr.currentWorld = 1;
        vr.isRewardTrial = (rand <= vr.rewardProbability);
    end
    
    vr = outputVirmenTrigger(vr);
    
    if vr.isCueTrial && (vr.position(2) > vr.CueRevealPosition)
        vr.currentWorld = 2;
    else
        vr.currentWorld = 1;
    end
    
    vr = collectBehaviorIter_TMaze(vr);
    vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed

    % Give Reward if in world 2
    if (vr.currentWorld == 2) && (vr.position(2) > vr.rewardLocation) && vr.isRewardTrial
        if (vr.numRewardsThisTrial < vr.numRewardsPerTrial)
            vr = giveRecordProbReward(vr, vr.correctRewardProbability);
            vr.numRewardsThisTrial = vr.numRewardsThisTrial + 1;
        else
            vr.behaviorData(9,vr.trialIterations) = 0;
        end
    else
        vr.behaviorData(9,vr.trialIterations) = 0;
    end



% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)

vr = updateLivePlots_linearMaze(vr);
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats_linearMaze(vr)
delete(instrfind);