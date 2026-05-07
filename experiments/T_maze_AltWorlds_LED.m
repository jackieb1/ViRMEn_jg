function code = T_maze_AltWorlds_LED
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
vr.trialSwitch1 = 1;
vr.trialSwitch2 = 125;
vr.worldsAvailable = [1 2];
vr.worldProbability = [0.5 0.5];
vr.currentWorld = 2;
% vr.biasCorrection = true;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
if isTrialStart(vr)
    vr = updateLivePlots(vr);
    if vr.numRewards >= vr.maxNumRewards
        vr.experimentEnded = true;
    end
%     disp(num2str(vr.numTrials));
    if vr.numTrials == vr.trialSwitch1
        disp(['Switched worlds after trial ' num2str(vr.numTrials)]);
        vr.worldsAvailable = [3 4];
        vr.nextWorld = chooseNextWorld(vr);
        vr = turnOnLED(vr);
    end
    if vr.numTrials == vr.trialSwitch2
        disp(['Switched worlds after trial ' num2str(vr.numTrials)]);
        vr.worldsAvailable = [1 2];
        vr.nextWorld = chooseNextWorld(vr);
        vr = turnOffLED(vr);
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
vr = turnOffLED(vr);
vr = clearAnalogChannels(vr);
savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats(vr);

