function code = linearTrack_flowStop_noReward
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
    vr = initDAQ(vr);
    vr = initLivePlots_linearMaze(vr);
    vr.numTrials = 0;
    
    % Maze parameters
    vr = initLinearTrack(vr); % place before initDAQ to activate teensy
    vr.rewardLocation = 350;
    
    % Forward velocity pulse parameters
    vr.pauseYTrigger = vr.mazeLength * 2;
    vr.totalMazeLength = vr.mazeLength;
    vr.pauseYPos = 50;
    vr.fractionTrials = 1;
    vr.pauseLength_s = 1;
    vr.initialGain = vr.ops.forwardGain;
    vr.inPause = 0;
    vr.pauseTrial = 0;

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % Loop maze
    if vr.position(2) > vr.mazeLength
        vr = endLinearTrackTrial(vr);
        vr = initLinearTrackTrial(vr);
%         vr = updateLivePlots_linearMaze(vr);

        %  brief (1 s) halts (mismatch; one perturbation every 15 s on average)
        if (rand <= vr.fractionTrials) && ~(vr.inPause)
            disp([num2str(vr.numTrials) ' Pause trial']);
            vr.pauseYTrigger = vr.pauseYPos;
            vr.pauseTrial = 1;
        else
            vr.pauseYTrigger = vr.mazeLength * 2;
            disp([num2str(vr.numTrials) ' Not pause trial']);
            vr.pauseTrial = 0;
        end
        
    end

    if (vr.pauseTrial) &&(vr.position(2) >= vr.pauseYTrigger) && (~vr.inPause)
        vr.pauseYTrigger = vr.mazeLength * 2;
        vr.startPause = tic;
        vr.inPause = 1;
        vr.ops.forwardGain = 0;
        disp('Pause start');
    end
    
    if (vr.inPause) && (toc(vr.startPause) < vr.pauseLength_s)
        vr.ops.forwardGain = 0;
    elseif (vr.inPause) && (toc(vr.startPause) >= vr.pauseLength_s)
        disp('Pause end');
        vr.ops.forwardGain = vr.initialGain;
        vr.inPause = 0;
        vr.pauseTrial = 0;
    end
    
    vr = outputVirmenTrigger(vr);
    vr = collectBehaviorIter_TMaze(vr, vr.inPause);
    vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
    vr.behaviorData(9,vr.trialIterations) = 0; % Set reward to 0 always

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)

vr = updateLivePlots_linearMaze(vr);
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats_linearMaze(vr)
delete(instrfind);