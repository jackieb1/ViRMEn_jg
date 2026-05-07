function code = T_maze_associationSwitch
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

% Version-specific parameters
vr.totalMazeLength = vr.floorLength + vr.cueLength;
vr.YTriggerPosition = 150;
vr.YTrigger = vr.YTriggerPosition;
vr.inWorldChange = 0;
vr.worldsAvailable = [1 2];
vr.worldProbability = [0.5 0.5];
vr.currentWorld = 3;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
if isTrialStart(vr)
    vr = updateLivePlots(vr);
    if vr.numRewards >= vr.maxNumRewards
        vr.experimentEnded = true;
    end
    vr.nextWorld = 3;
    vr = initTrial(vr);
    
    vr.YTrigger = vr.YTriggerPosition;
    vr.inWorldChange = 0;
end

vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze(vr);
%vr = adjustFriction_dan(vr);
vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
vr = checkforTrialEndPosition_Tmaze(vr);
vr = waitForNextTrial(vr);

if vr.position(2) >= vr.YTrigger
    vr.currentWorld = randsample(vr.worldsAvailable, 1, true, vr.worldProbability);
    vr.worlds{vr.currentWorld}.surface.visible(:) = 1;
    vr.worlds{vr.currentWorld}.backgroundColor = [vr.backgroundR_val vr.backgroundG_val vr.backgroundB_val];
    vr.inWorldChange = 1;
    vr = disableYTrigger(vr);
end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = clearAnalogChannels(vr);
savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats(vr);

