function code = linearTrack_noReward_4towers_freeze_long
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
    
    % Initialize VR
    vr.debugMode = false;
    vr.ops = getRigInfo();
    vr = makeVirmenDir(vr);
    vr = initLinearTrack(vr);
    vr = initDAQ(vr);
    vr = initLivePlots_linearMaze(vr);
    
    % Initialize maze
    vr.totalMazeLength = vr.mazeLength;
    vr.freezeYPos = [50 150 250 350];
    vr.freezeChecked = false(size(vr.freezeYPos));
    vr.freezeDur = 4;
    vr.isFrozen = 0;
    vr.freezeTimer = uint64(0); % placeholder for tic handle
    vr.freezeProb = 1/3; 
    % aiming for average 15 sec between freeze if 3 trials/mins
    % so if about 5 sec between towers, 1 in 3 towers should have freeze
    

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % Loop maze
    if vr.position(2) > vr.mazeLength
        vr = endLinearTrackTrial(vr);
        vr = initLinearTrackTrial(vr);
        vr = updateLivePlots_linearMaze(vr);
        vr.currentWorld = randsample(vr.worldsAvailable, 1, true, vr.worldProbability);
        vr.numRewardsThisTrial = 0;
        vr.freezeChecked = false(size(vr.freezeYPos));
    end
    
    vr = multi_freeze(vr);
    vr = outputVirmenTrigger(vr);
    vr = collectBehaviorIter_TMaze(vr, vr.isFrozen);
    vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)

vr = updateLivePlots_linearMaze(vr);
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats_linearMaze(vr)
delete(instrfind);