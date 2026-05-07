function code = T_maze_worldChange150vu
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

% Version-specific parameters
vr.totalMazeLength = vr.floorLength + vr.cueLength;
vr.YTrigger = vr.totalMazeLength * 2;
vr.fractionTrials = 0.5;
vr.YTriggerPosition = 280;
vr.inWorldChange = 0;

vr = initDAQ(vr);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze(vr, vr.inWorldChange);
%vr = adjustFriction_dan(vr);
vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
vr = checkforTrialEndPosition_Tmaze(vr);
vr = waitForNextTrial(vr);

if vr.position(2) >= vr.YTrigger
    vr = changeWorld(vr);
    vr.inWorldChange = 1;
    vr = disableYTrigger(vr);
end

if isTrialStart(vr)
    vr = initTrial(vr);
    if rand <= vr.fractionTrials
        vr.YTrigger = vr.YTriggerPosition;
    end
    vr.inWorldChange = 0;
end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = clearAnalogChannels(vr);
[vr,sessionData] = collectTrialData(vr);
%vr = makeTMazeFigs(vr,sessionData);
