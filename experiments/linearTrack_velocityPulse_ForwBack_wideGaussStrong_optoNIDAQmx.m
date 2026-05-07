function code = linearTrack_velocityPulse_ForwBack_wideGaussStrong_optoNIDAQmx
% linearTrackNew   Code for the ViRMEn experiment linearTrackNew.
%   code = linearTrackNew   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.
% copied from linearTrack_velocityPulse_ForwAndBack_wideGaussStrong_noReward


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
    vr.driftPulseSd = 0.375*1.5;
    vr.driftPulseMu = vr.driftPulseSd * 4;
    vr.driftPulseHeight_const = 400;
    vr.driftConstantLength = 1.5;
    vr.driftTime = 4.5;
    
    vr.optoOn = 0;
    vr.optoTimeOn = 0;
    vr.optoDur = 4.5;
    vr.optoNum = zeros(3, 1); % counter for each trial type
    vr.optoTriggered = 0; % flag to prevent re-triggering opto stim in same trial
    
    % 7.5 Hz train for 4.5s
    vr.vHigh = 2.75; % pulse amp V
    vr.pulse_ms = 30; % pulse dur ms
    vr.pulse_freq = 4.5; % Hz
    vr.Rate = 1e3;
    vr.yPulse = makePulseTrain(vr.Rate, 7.5, 0.03, 4.5, vr.vHigh);
    
    % 2 trials per trial type in probe block
    % 9 trials per trial type in stim block
    % 6 probe blocks in total
    vr.n_trialsPerProbeBlock = 2;
    vr.n_trialsPerStimBlock = 9;
    vr.n_probeBlocks = 6;
    
    vr = setupAO_PFI0(vr);
    
    % create trial type + stim order
    vr.trialType = [1]; % dummy initialization
    while vr.trialType(1) ~= 3 % ensure first trial is control
        vr = constructPulseOptoTrialSequence(vr, vr.n_trialsPerProbeBlock, vr.n_trialsPerStimBlock, vr.n_probeBlocks);
    end
    vr.trialTypeLabels = ["forward" "backward" "control"];
    vr.trialStimLabels = ["probe" "stim"];
    
    vr = setPulseAndOptoTrial(vr);

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % Loop maze
    if vr.position(2) > vr.mazeLength
        vr = endLinearTrackTrial(vr);
        vr = initLinearTrackTrial(vr);
%         vr = updateLivePlots_linearMaze(vr);
        if vr.numTrials+1 > max(size(vr.trialType))
            vr.experimentEnded = true;
        else
            vr = setPulseAndOptoTrial(vr);
        end
    end

    vr = outputVirmenTrigger(vr);
    vr = collectBehaviorIter_TMaze(vr, vr.inDriftPulse, vr.forwardBias, vr.optoOn, vr.vHigh);
    vr = forwardDriftPulse(vr);
    if vr.isStimTrial && vr.optoTriggered == 0
        vr = posTriggerWithVelocityPulseOptoNIDAQmx(vr);
    end
    
    if vr.optoOn 
        t_Opto = toc(vr.optoTimeOn);
        if t_Opto > vr.optoDur + 0.2 % extra time buffer
            vr = aoEnable(vr, false);
            vr.optoOn = 0;
            disp('Opto Off');
        end
    end
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
releaseAO(vr);
resetNIDAQmx;