function code = linearTrack_2worlds_ITI_rewardProbInWorldAt200vu
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
vr.debugMode = false;
vr.ops = getRigInfo();
vr = makeVirmenDir(vr);
vr = initLinearTrack_new(vr);
vr = initDAQ(vr);
vr = initLivePlots_linearMaze(vr);
vr = selectRewardedWorld(vr);
vr.rewardLocation = 225;
vr.rewardZoneRadius = 25;
vr.probAutomaticReward = 1;
vr.isAutomaticReward = 1;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
if isTrialStart(vr)
    vr = updateLivePlots_linearMaze(vr);
    if vr.numRewards >= vr.maxNumRewards
        vr.experimentEnded = true;
    end
    vr = initTrial(vr);
    if rand <= vr.probAutomaticReward
        vr.isAutomaticReward = 1;
    else
        vr.isAutomaticReward = 0;
    end
    vr.numRewardsThisTrial = 0;
end

if (abs(vr.position(2)-vr.rewardLocation)<vr.rewardZoneRadius)
    if vr.numRewardsThisTrial < vr.numRewardsPerTrial
        if vr.isAutomaticReward || vr.isLick
            disp(['World Reward Prob: ' num2str(vr.correctRewardProbability(vr.currentWorld))])
            vr = giveRecordProbReward(vr, vr.correctRewardProbability(vr.currentWorld));
            vr.numRewardsThisTrial = vr.numRewardsThisTrial + 1;
        end
    end
end

vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze(vr, vr.isAutomaticReward, vr.numRewardsThisTrial);
vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
vr = checkforTrialEndPosition_linearTrack_noReward(vr);
vr = waitForNextTrial(vr);

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
