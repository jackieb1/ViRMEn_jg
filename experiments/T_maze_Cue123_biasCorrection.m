function code = T_maze_Cue123_biasCorrection
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
vr.worldsAvailable = [1 2 3];
vr.biasCorrection = true;
vr = initDAQ(vr);
vr = initLivePlots(vr);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
if isTrialStart(vr)
%     vr = updateLivePlots(vr);
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
vr = updateLivePlots(vr);
vr = clearAnalogChannels(vr);
savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats(vr);

