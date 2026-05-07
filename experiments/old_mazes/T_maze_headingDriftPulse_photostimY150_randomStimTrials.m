function code = T_maze_headingDriftPulse_photostimY150_randomStimTrials
% T_maze   Code for the ViRMEn experiment T_maze.
%   code = T_maze   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT

% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)
vr.debugMode = false;
vr.ops = getRigInfo();
vr = makeVirmenDir(vr);
vr = initTMaze(vr);
vr = initDAQ(vr);
vr = initLivePlots(vr);

% Maze specific parameters
vr.totalMazeLength = vr.floorLength + vr.cueLength;
vr.isHeadingPulseTrial = 0;
vr.driftYTrigger = vr.totalMazeLength * 2;
vr.driftYPos = 150;
vr.inDriftPulse = 0;
vr.dp4offset = 0;
vr.fractionHeadingPulseTrials = 0.3;
vr.driftPulseSd = 0.375;
vr.driftPulseMu = vr.driftPulseSd * 4;
vr.driftPulseHeight = 0.06;
vr.minAccuracy = 0.60;
vr.accuracyEvalWindow = 100;

% Photostimulation parameters
vr.stimTrialSegment = 'yTrigger';
vr.optoYTrigger = 150;
vr.stimTrialProbability = 1.0;
vr.isStimTrial = 0;
vr.stimOn = 0;
vr.optoWasOn = 0;
vr.maxStimOnTime_s = 5;


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
if isTrialStart(vr)
%     vr = updateLivePlots(vr);
    if vr.numRewards >= vr.maxNumRewards
        disp('Ending session because reached max number of rewards.')
        vr.experimentEnded = true;
    end
    
    if (vr.numTrials > vr.accuracyEvalWindow+25)
        accuracy = mean(vr.correctTrials(end-vr.accuracyEvalWindow:end));
        if (accuracy < vr.minAccuracy)
            disp('Ending session because of low accuracy.')
            vr.experimentEnded = true;
        end
    end
    vr = initTrial(vr);
    
    % Heading pulse parameters
    if rand <= vr.fractionHeadingPulseTrials
        vr.isHeadingPulseTrial = 1;
        vr.driftYTrigger = vr.driftYPos;
        disp('Heading pulse trial.')
        
        % Randomly choose pulse going left or right
        pulseDirection = (randi([0 1]) -0.5)*2; % -1 or 1
        vr.driftPulseHeight = vr.driftPulseHeight * pulseDirection;
    else
        vr.isHeadingPulseTrial = 0;
        vr.driftYTrigger = vr.totalMazeLength * 2; % gain change never triggered
    end
    vr.inDriftPulse = 0;
    vr.dp4offset = 0;
    
    % Photostim parameters
    vr.optoWasOn = 0;
    if rand <= vr.stimTrialProbability
        vr.isStimTrial = 1;
    else
        vr.isStimTrial = 0;
    end
end

vr = checkExecuteStim(vr);
vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze_ballMvmts(vr, vr.inDriftPulse, vr.dp4offset, vr.stimOn);
vr = headingDriftPulse(vr);
%vr = adjustFriction_dan(vr);
vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
vr = checkforTrialEndPosition_Tmaze(vr);
vr = waitForNextTrial(vr);


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = updateLivePlots(vr);
vr = clearAnalogChannels(vr);
savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats(vr);
