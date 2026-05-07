function code = linearTrack_noReward_teleport
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
    vr.rewardLocation = 350;
    
    vr.trialStartTeleport = 1;
    vr.teleportProb = 2/3;
    vr.teleportBackProb = 0.5;
    vr.isTeleportTrial = 0;
    vr.isTeleportBack = 0;
    vr.teleportLocation = 200;
    vr.teleportDistance = 100;
    vr.teleported = 0;
    
    

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % Loop maze
    if vr.position(2) > vr.mazeLength
        vr = endLinearTrackTrial(vr);
        vr = initLinearTrackTrial(vr);
        vr.currentWorld = randsample(vr.worldsAvailable, 1, true, vr.worldProbability);
        vr = updateLivePlots_linearMaze(vr);
        if (vr.numTrials >= vr.trialStartTeleport)
            vr.isTeleportTrial = rand <= vr.teleportProb;
        else
            vr.isTeleportTrial = 0;
        end
        vr.isTeleportBack = rand <= vr.teleportBackProb;
        vr.teleported = 0;
        disp(['Trial: ' num2str(vr.numTrials) ', Teleport Trial: ' num2str(vr.isTeleportTrial) ', Teleport Back: ' num2str(vr.isTeleportBack)])
    end
    
    if (vr.position(2) >= vr.teleportLocation) && (vr.isTeleportTrial) && (~vr.teleported)
%         vr = collectBehaviorIter_TMaze(vr, vr.isTeleportTrial);
%         vr = collectBehaviorIter_TMaze(vr, vr.isTeleportBack);
        if vr.isTeleportBack
            vr.position(2) = vr.teleportLocation - vr.teleportDistance;
        else
            vr.position(2) = vr.teleportLocation + vr.teleportDistance;
        end
        vr.teleported = 1;
    end

    vr = outputVirmenTrigger(vr);
    vr = collectBehaviorIter_TMaze(vr);
    vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)

vr = updateLivePlots_linearMaze(vr);
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats_linearMaze(vr)
delete(instrfind);