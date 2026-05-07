function code = T_maze_headingDriftPulse
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

% Maze specific parameters
vr.totalMazeLength = vr.floorLength + vr.cueLength;
vr.YTrigger = vr.totalMazeLength * 2;
vr.XTrigger = 20;
vr.inDriftPulse = 0;
vr.dp4offset = 0;
vr.fractionInArm = 0.5; %0.5
vr.fractionTrials = 0.3; %0.3
vr.driftPulseSd = 0.15;
vr.driftPulseMu = vr.driftPulseSd * 4;
vr.driftPulseHeight = 0.03;


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze(vr, vr.inDriftPulse, vr.dp4offset);
vr = headingDriftPulse(vr);
%vr = adjustFriction_dan(vr);
vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
vr = checkforTrialEndPosition_Tmaze(vr);
vr = waitForNextTrial(vr);

if isTrialStart(vr)
    vr = initTrial(vr);
    if rand <= vr.fractionTrials
        if rand <= vr.fractionInArm
            vr.XTrigger = 4; % 1/3 to reward zone
            vr.YTrigger = vr.totalMazeLength * 2; % Past end of maze - do not trigger on y.
        else
            vr.Xtrigger = 20; % Past reward zone - do not trigger on x.
            vr.YTrigger = 300*0.75; % Halfway through 1/2 delay
        end
    end
    
    vr.inDriftPulse = 0;
    vr.dp4offset = 0;
    % Randomly choose pulse going left or right
    pulseDirection = (randi([0 1]) -0.5)*2; % -1 or 1
    vr.driftPulseHeight = vr.driftPulseHeight * pulseDirection;
end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = clearAnalogChannels(vr);
[vr,sessionData] = collectTrialData(vr);
%vr = makeTMazeFigs(vr,sessionData);
