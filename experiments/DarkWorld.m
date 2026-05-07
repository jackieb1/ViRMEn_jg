 function code = DarkWorld
% CY: DarkWorld has nothing in it to display and randomly distributes
% reward if mouse is running
%   code = DarkWorld   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.

% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT


% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)
vr.debugMode = false;
vr.ops = getRigInfo(); % contains info on reward magnitude
vr = makeVirmenDir(vr); % creates a directory to store data to
vr.taskName = 'dark';

vr.pitchGain = 1;
vr.yawGain = 1;
vr.currentWorld = 1; % fixed at 1
vr = initDAQ(vr); 
vr = initCounters(vr);  % CY note: won't need most of them
vr.iterSinceLastRew = inf; % new counter specific to this experiment

% custom variables that can be changed in virmen gui
vr.runningThres = eval(vr.exper.variables.runningThres);
vr.rewardProb = eval(vr.exper.variables.rewardProb);
vr.minIterBetweenRew = eval(vr.exper.variables.minIterBetweenRew);
vr.maxRewAllowed = eval(vr.exper.variables.maxRewAllowed);


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
% vr = outputVirmenTrigger(vr); % 08/20/21 CY added to aid sync b/w virmen and ephys
% vr.totIterations = vr.totIterations + 1; % use total iteration to decide high low state, not trialIterations!
% vr = changeVirmenHighLow(vr); % 02/09/2022 CY changed pulses to high-low states

vr = collectBehaviorIter_TMazeCYJS(vr); % collect behavior data
% vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
vr = checkForDarkWorldRunningRew(vr); % Check for forward velocity, randomly dispense reward if running above threshold
% stop the experiment if max amount of rewards received
if vr.numRewards >= vr.maxNumRewards
    vr.experimentEnded = 1;
end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
if ~vr.debugMode
    stop(vr.ai),
    delete(vr.ai),
    delete(vr.ao),
end
vr = saveTrialData(vr); % dark world is one big trial
