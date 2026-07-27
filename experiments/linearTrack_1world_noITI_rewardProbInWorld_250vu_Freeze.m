function code = linearTrack_1world_noITI_rewardProbInWorld_250vu_Freeze
% Linear Track   Code for the ViRMEn experiment T_maze.
%   code = T_maze   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT

% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)
% wrap world
vr.mazeLength = eval(vr.exper.variables.mazewidth);
vr = wrapLinearWorlds(vr);

vr.debugMode = false;
vr.ops = getRigInfo();
vr = makeVirmenDir(vr);
vr = initLinearTrack_new(vr);
vr = initDAQ(vr);
vr = initLivePlots_linearMaze(vr);
vr.rewardLocation = 225;
vr.rewardZoneRadius = 25;
vr.probAutomaticReward = 1;
vr.isAutomaticReward = 1;

vr.isFreezeTrial = 0;
vr.freezeYTrigger = vr.mazeLength * 4;
vr.totalMazeLength = vr.mazeLength;
vr.freezeYPos = 100;
vr.freezeDur = 3;
vr.isFrozen = 0;
vr.froze = 0;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

if (abs(vr.position(2)-vr.rewardLocation)<vr.rewardZoneRadius)&&(vr.inITI==0)
    if vr.numRewardsThisTrial < vr.numRewardsPerTrial
        if vr.isAutomaticReward || vr.isLick
            vr = giveRecordProbReward(vr, 1);
            vr.numRewardsThisTrial = vr.numRewardsThisTrial + 1;
        end
    end
end

vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze(vr, vr.isFrozen);
vr = freeze(vr);
vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
% vr = checkforTrialEndPosition_linearTrack_noReward(vr);
% vr = waitForNextTrial(vr);

if vr.position(2) > vr.mazeLength
    vr = endLinearTrackTrial(vr);
    vr = initLinearTrackTrial(vr);
    vr = updateLivePlots_linearMaze(vr);
    vr.currentWorld = randsample(vr.worldsAvailable, 1, true, vr.worldProbability);
    vr.numRewardsThisTrial = 0;
    
    vr.isFreezeTrial = randi([0 1]);
    vr.isFrozen = 0;
    vr.froze = 0;

    if vr.isFreezeTrial
        vr.freezeYTrigger = vr.freezeYPos;
        disp("Freeze Trial");
    else
        disp("Regular Trial");
    end
end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
vr = writePerformanceToExcel(vr);
vr = updateLivePlots_linearMaze(vr);
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats_linearMaze(vr)
delete(instrfind);
