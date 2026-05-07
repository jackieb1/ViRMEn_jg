function code = T_maze_teleport
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
vr.teleportDist = 100; % distance
vr.teleportDir = 1; % direction
vr.teleportTime = 0;
vr.teleported = 0;
vr.tPastYThresh = 0;
vr.startTimer = 0;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
if isTrialStart(vr)
    vr = updateLivePlots(vr);
    if vr.numRewards >= vr.maxNumRewards
        vr.experimentEnded = true;
    end
    vr = initTrial(vr);
    vr.teleportDir = randi([-1 1]);
    vr.isTeleportTrial = vr.teleportDir ~= 0;
    vr.teleportTime = unifrnd(1, 4);
    vr.teleported = 0;
    vr.tPastYThresh = 0;
    vr.startTimer = 0;
    if vr.isTeleportTrial
        disp(["Teleport Trial" vr.teleportTime vr.teleportDir]);
    else
        disp("Regular Trial");
    end
end

if (vr.position(2) > 50) && (vr.startTimer == 0)
    vr.tPastYThresh = tic;
    vr.startTimer = 1;
    disp("Start timer");
end
if vr.startTimer
    t = toc(vr.tPastYThresh);
else
    t = 0;
end
if (t >= vr.teleportTime) && (vr.isTeleportTrial == 1) && (vr.teleported == 0)
    if vr.position(2) > 300 % make sure there is no teleport at T junction
        vr.teleported = -1;
    else
        if vr.teleportDir > 0
            vr.position(2) = min(300, vr.position(2)+vr.teleportDist);
            disp("Teleport Forward");
        else
            vr.position(2) = max(10, vr.position(2)-vr.teleportDist);
            disp("Teleport Backward");
        end
        vr.teleported = 1;
    end
end


vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze(vr, vr.isTeleportTrial, vr.teleportDist, vr.teleportDir, vr.teleportTime, vr.teleported);
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

