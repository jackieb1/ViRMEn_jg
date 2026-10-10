function code = linearTrack_noReward_cuePredictableThenProbNoPopUP

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
    vr.switchTrial = 50;
    vr.cue_location = 50;
    vr.cue_appeared = 0;
    vr.nextIsCue = 0;
    vr.cueProbabilityHigh = 0.8;
    vr.noCueCount = 0;
    vr.switchNoCueCount = 30;
    vr.cueProbability = 0.2;
    vr.cueCount = 0;
    vr.switchCueCount = 30;

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % Loop maze
    if vr.position(2) > vr.mazeLength/2
        vr = endLinearTrackTrial(vr);
        vr = initLinearTrackTrial_doubleLength(vr);
        if (vr.numTrials < vr.switchTrial-1) % 100% cue
            if (vr.nextIsCue)
                vr.currentWorld = 4;
                vr.nextIsCue = 1;
            else
                vr.currentWorld = 2;
                vr.nextIsCue = 1;
            end
        elseif vr.noCueCount < vr.switchNoCueCount % 80% cue
            vr.nextnext = rand < vr.cueProbabilityHigh;
            if (vr.nextIsCue)
                if (vr.nextnext)
                    vr.currentWorld = 4;
                    vr.nextIsCue = 1;
                else
                    vr.currentWorld = 3;
                    vr.nextIsCue = 0;
                end
            else
                vr.noCueCount = vr.noCueCount + 1;
                if (vr.nextnext)
                    vr.currentWorld = 2;
                    vr.nextIsCue = 1;
                else
                    vr.currentWorld = 1;
                    vr.nextIsCue = 0;
                end
            end
        elseif vr.cueCount < vr.switchCueCount % 20% cue
            vr.nextnext = rand < vr.cueProbability;
            if (vr.nextIsCue)
                vr.cueCount = vr.cueCount + 1;
                if (vr.nextnext)
                    vr.currentWorld = 4;
                    vr.nextIsCue = 1;
                else
                    vr.currentWorld = 3;
                    vr.nextIsCue = 0;
                end
            else
                if (vr.nextnext)
                    vr.currentWorld = 2;
                    vr.nextIsCue = 1;
                else
                    vr.currentWorld = 1;
                    vr.nextIsCue = 0;
                end
            end
        else % 0% cue
            if (vr.nextIsCue)
                vr.currentWorld = 3;
                vr.nextIsCue = 0;
            else
                vr.currentWorld = 1;
                vr.nextIsCue = 0;
            end
        end
        disp(['World: ' num2str(vr.currentWorld)]);
        disp(['No cues so far: ' num2str(vr.noCueCount)]);
        disp(['Cues so far: ' num2str(vr.cueCount)]);
        vr = updateLivePlots_linearMaze(vr);
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