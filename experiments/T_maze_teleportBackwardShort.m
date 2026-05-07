function code = T_maze_teleportBackwardShort
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

vr.isTeleportTrial = 0;
vr.teleportYTrigger = vr.mazeLength * 4;
vr.totalMazeLength = vr.mazeLength;
vr.teleportYPos = 200;
vr.teleported = 0;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
if isTrialStart(vr)
    vr = updateLivePlots(vr);
    if vr.numRewards >= vr.maxNumRewards
        vr.experimentEnded = true;
    end
    vr = initTrial(vr);
    vr.isTeleportTrial = randi([0 1]);
    vr.teleported = 0;
    if vr.isTeleportTrial
        vr.teleportYTrigger = vr.teleportYPos;
        disp(["Teleport Trial" ]);
    else
        disp("Regular Trial");
    end
end

if (vr.position(2) >= vr.teleportYTrigger) && (vr.teleported == 0)
    vr.teleported = 1;
    vr.teleportYTrigger = vr.totalMazeLength * 4; % reset y trigger until next trial (reset in chooseNextGainChangeYPosition)
    vr.position(2) = 100;
    disp('Teleported');
end

vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze(vr, vr.isTeleportTrial, vr.teleported);
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

