function code = T_maze_warmup_training
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

vr.exper.variables.floorLength = 43;
vr.exper.variables.cueLength = 43;
vr.correctTrials = [];
vr.switchPerformanceThreshold = 5.0;
vr.switchPerformanceWindowTrials = 2;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
if isTrialStart(vr)
    vr = updateLivePlots(vr);
    if length(vr.correctTrials)>vr.switchPerformanceWindowTrials
        vr.trialRate = vr.numTrials/(toc(vr.sessionStartTime)/60);
        vr.performanceCheck = vr.trialRate > vr.switchPerformanceThreshold;
        if vr.performanceCheck
            vr.exper.variables.floorLength = 75;
            vr.exper.variables.cueLength = 75;
            fprintf('Starting Maze B ')
        end
    end
    if vr.numRewards >= vr.maxNumRewards
        vr.experimentEnded = true;
    end
    vr = initTrial(vr);
end

vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze(vr);
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

