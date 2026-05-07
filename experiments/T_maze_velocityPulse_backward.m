function code = T_maze_velocityPulse_backward
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

vr.isPulseTrial = 0;
vr.pulseDir = 0;

vr.driftYTrigger = vr.mazeLength * 4;
vr.totalMazeLength = vr.mazeLength;
vr.driftYPos = 150;
vr.inDriftPulse = 0;
vr.forwardBias = 0;
vr.driftPulseSd = 0.375*1.5;
vr.driftPulseMu = vr.driftPulseSd * 4;
vr.driftPulseHeight_const = 8;
vr.driftPulseHeight = 0;
vr.driftConstantLength = 1.5;
vr.driftTime = 4.5;
vr.pulsed = 0;


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
if isTrialStart(vr)
    vr = updateLivePlots(vr);
    if vr.numRewards >= vr.maxNumRewards
        vr.experimentEnded = true;
    end
    vr = initTrial(vr);
    vr.pulseDir = randi([-1 0]);
    vr.isPulseTrial = vr.pulseDir ~= 0;
    vr.inDriftPulse = 0;
    vr.forwardBias = 0;
    vr.pulsed = 0;

    if vr.isPulseTrial
        vr.driftPulseHeight = vr.driftPulseHeight_const * vr.pulseDir;
        vr.driftYTrigger = vr.driftYPos;
        disp("Pulse Trial");
    else
        vr.driftYTrigger = vr.mazeLength * 4; % gain change never triggered
        disp("Regular Trial");
    end
end

vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze(vr, vr.inDriftPulse, vr.forwardBias);
vr = forwardDriftPulse_TMaze(vr);
%vr = adjustFriction_dan(vr);
vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
vr = checkforTrialEndPosition_Tmaze(vr);
vr = waitForNextTrial(vr);

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = clearAnalogChannels(vr);
savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats(vr);

