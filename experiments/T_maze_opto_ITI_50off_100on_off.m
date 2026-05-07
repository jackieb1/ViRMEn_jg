function code = T_maze_opto_ITI_50off_100on_off
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

% Experiment-specific parameters
vr.trialBlocki = 1;
vr.trialBlocks = [50, 100, inf];
vr.optoBlocks = [0, 1, 0];
vr.optoOn = 0;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze(vr, vr.optoOn);
%vr = adjustFriction_dan(vr);
vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
vr = checkforTrialEndPosition_Tmaze(vr);
vr = waitForNextTrial(vr);

if isTrialStart(vr)
    vr = initTrial(vr);
end

if vr.inITI
    if vr.numTrials > sum(vr.trialBlocks(1:vr.trialBlocki))
        vr.trialBlocki = vr.trialBlocki + 1;
    end
    vr.optoOn = vr.optoBlocks(vr.trialBlocki);
else
    vr.optoOn = 0;
end

outputSingleScan(vr.optoDIO,[vr.optoOn]);

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = clearAnalogChannels(vr);
[vr,sessionData] = collectTrialData(vr);
%vr = makeTMazeFigs(vr,sessionData);
