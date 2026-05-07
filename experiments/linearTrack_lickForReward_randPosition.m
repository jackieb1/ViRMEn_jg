function code = linearTrack_lickForReward_randPosition
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
    disp(vr.worlds)
    vr = wrapLinearWorlds(vr);
    
    % Initialize VR
    vr.debugMode = false;
    vr.ops = getRigInfo();
    vr = makeVirmenDir(vr);
    vr = initDAQ(vr);
    vr = initLivePlots_linearMaze(vr);
    
    % Initialize maze
    vr = initLinearTrack(vr);
    vr.rewardRadius = 20;
    vr.rewardLocation = randi([1, vr.mazeLength]);
    vr.numRewardsPerLocation = 1;
    vr.numRewardsThisLocation = 0;
   

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    if vr.numRewards >= vr.maxNumRewards
        vr.experimentEnded = true;
    end

    % Loop maze
    if vr.position(2) > vr.mazeLength
        vr.numTrials = vr.numTrials + 1;
        vr.position(2) = vr.position(2) - vr.mazeLength;
        vr.trialTimeTrials = [vr.trialTimeTrials toc(vr.trialTimer)];
        vr.trialTimer = tic;
        vr = saveTrialData(vr);
        vr = updateLivePlots_linearMaze(vr);
        vr.numRewardsThisLocation = 0;
    end

    vr = outputVirmenTrigger(vr);
    vr = collectBehaviorIter_TMaze(vr);
    vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
%     isLick = vr.isLick;
%     disp(isLick)
    % Give reward in reward patch
    vr.behaviorData(9,vr.trialIterations) = 0; % default is no reward, overwrite below if reward is given
    if abs(vr.position(2) - vr.rewardLocation) < vr.rewardRadius
        if vr.isLick && (vr.numRewardsThisLocation < vr.numRewardsPerLocation)
            vr = giveRecordProbReward(vr, vr.correctRewardProbability); % also logs reward in vr.behaviorData
            vr.numRewardsThisLocation = vr.numRewardsThisLocation + 1;
        end
    end


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)

    vr = updateLivePlots_linearMaze(vr);
    if vr.numTrials > 0
        [vr,sessionData] = collectTrialData(vr);
    end
    printSessionStats_linearMaze(vr)
    delete(instrfind);