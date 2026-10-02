function code = dark_linearTrack_probRewardEvery200vu_probRewardEvery30s
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
    vr.worlds{vr.currentWorld}.backgroundColor = [0 0 0];
    vr.lastRewardLocation = 0;
    vr.rewardDistance = 200;
    vr.reward_prob_loc = 0.25;
    vr.rewardTime = 20;
    vr.reward_prob_time = 0.25;
    vr.reward_given = false;

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    if vr.numRewards >= vr.maxNumRewards
        vr.experimentEnded = true;
    end

    % Loop maze
    if vr.position(2) > vr.mazeLength
        vr.trialEnded = 1;
        vr.lastRewardLocation = 0;
        vr.numTrials = vr.numTrials + 1;
        vr.position(2) = vr.position(2) - vr.mazeLength;
        vr.trialTimeTrials = [vr.trialTimeTrials toc(vr.trialTimer)];
        vr.trialTimer = tic;
        vr = saveTrialData(vr);
        vr = updateLivePlots_linearMaze(vr);
    end

    vr = outputVirmenTrigger(vr);
    vr = collectBehaviorIter_TMaze(vr);
    vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed

    if vr.position(2) > (vr.lastRewardLocation + vr.rewardDistance)
        disp('Location');
        vr = giveRecordProbReward(vr, vr.reward_prob_loc);
        vr.lastRewardLocation = vr.position(2);
        if vr.reward_given
            vr.lastRewardTime = tic;
        end
    end

    if isfield(vr, 'lastRewardTime')   
        if toc(vr.lastRewardTime) > vr.rewardTime
            disp('Time');
            vr = giveRecordProbReward(vr, vr.reward_prob_time);
            if vr.reward_given
                vr.lastRewardLocation = vr.position(2);
            end
            vr.lastRewardTime = tic;
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