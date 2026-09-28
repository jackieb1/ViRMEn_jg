function code = linearTrack_3cuesPerTrial_switchNewSet_ITI_noReward
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
    
    % Initialize VR
    vr.mazeLength = eval(vr.exper.variables.mazewidth);
    vr.debugMode = false;
    vr.ops = getRigInfo();
    vr = makeVirmenDir(vr);
    vr = initLinearTrack(vr);
    vr = initDAQ(vr);
    vr = initLivePlots_linearMaze(vr);
    
    % Initialize maze
    vr.CueRevealPositions = [50 150 250];
    vr.CueEndPositions = [100 200 300];
    vr.currentWorld = 1;
    vr.nextCue = 1;
    vr.cueHasAppeared = 0;
    vr.switchTrial = 50;
    
%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

    % Loop maze
    
    if isTrialStart(vr)
        if vr.numRewards >= vr.maxNumRewards
            vr.experimentEnded = true;
        end
        vr = initLinearTrackTrial_tj(vr);
        vr.cueHasAppeared = 0;
        vr.nextCue = 1;
    end
    
    vr = outputVirmenTrigger(vr);
    
    if vr.nextCue <= length(vr.CueRevealPositions)
        nextCueRevealPosition = vr.CueRevealPositions(vr.nextCue);
        nextCueEndPosition = vr.CueEndPositions(vr.nextCue);
        if (~vr.cueHasAppeared) && (vr.position(2) > nextCueRevealPosition)

            if (vr.numTrials >= vr.switchTrial)
                vr.currentWorld = 4+vr.nextCue; % 4 to switch to second set of cues
            else
                vr.currentWorld = 1+vr.nextCue;
            end
            disp([vr.currentWorld vr.nextCue])
            vr.cueHasAppeared = 1;
        end
        if vr.cueHasAppeared && (vr.position(2) > nextCueEndPosition)
            vr.nextCue = vr.nextCue + 1;
            vr.cueHasAppeared = 0;
        end
    end
    
    vr = collectBehaviorIter_TMaze(vr);
    vr.behaviorData(9,vr.trialIterations) = 0;
    vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
    vr = checkforTrialEndPosition_linearTrack_tj(vr);
    vr = waitForNextTrial(vr);

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)

vr = updateLivePlots_linearMaze(vr);
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats_linearMaze(vr)
delete(instrfind);