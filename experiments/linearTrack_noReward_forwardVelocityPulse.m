function code = linearTrack_noReward_forwardVelocityPulse
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
    vr.driftYTrigger = vr.mazeLength * 2;
    vr.totalMazeLength = vr.mazeLength;
    vr.driftYPos = 50;
    vr.inDriftPulse = 0;
    vr.forwardBias = 0;
    vr.fractionTrials = 0.67;
    vr.driftPulseSd = 0.375;
    vr.driftPulseMu = vr.driftPulseSd * 4;
    vr.driftPulseHeight_const = 200;
    
    
    

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % Loop maze
    if vr.position(2) > vr.mazeLength
        vr = endLinearTrackTrial(vr);
        vr = initLinearTrackTrial(vr);
%         vr = updateLivePlots_linearMaze(vr);

        if rand <= vr.fractionTrials
            vr.isHeadingPulseTrial = 1;
            vr.driftYTrigger = vr.driftYPos;
            % Randomly flip pulse going forward or backward
            pulseDirection = (randi([0 1]) -0.5)*2; % -1 or 1
            vr.driftPulseHeight = vr.driftPulseHeight_const * pulseDirection;
            disp([num2str(vr.numTrials) ' Velocity pulse trial: ' num2str(pulseDirection)]);
        else
            vr.isHeadingPulseTrial = 0;
            vr.driftYTrigger = vr.mazeLength * 2; % gain change never triggered
            disp([num2str(vr.numTrials) ' Not pulse trial']);
        end
        vr.inDriftPulse = 0;
        vr.forwardBias = 0;
    end

    vr = outputVirmenTrigger(vr);
    vr = collectBehaviorIter_TMaze(vr, vr.inDriftPulse, vr.forwardBias);
    vr = forwardDriftPulse(vr);
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