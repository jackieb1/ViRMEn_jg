function code = T_maze_noRewardWorld2
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

% Version-specific parameters
vr.trialBlocki = 1;
vr.trialBlocks = [50, 200, inf];
vr.noRewardWorld = 2;
vr.correctRewardProbabilityBlocks = [1.0 0.0 1.0];
vr.correctRewardProbability(vr.noRewardWorld) = vr.correctRewardProbabilityBlocks(vr.trialBlocki);

vr = initDAQ(vr);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze(vr, vr.correctRewardProbability(vr.noRewardWorld));
%vr = adjustFriction_dan(vr);
vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
vr = checkforTrialEndPosition_Tmaze(vr);
vr = waitForNextTrial(vr);

if isTrialStart(vr)
    vr = initTrial(vr);
    if vr.numTrials > sum(vr.trialBlocks(1:vr.trialBlocki))
        vr.trialBlocki = vr.trialBlocki + 1;
    end
    vr.correctRewardProbability(vr.noRewardWorld) = vr.correctRewardProbabilityBlocks(vr.trialBlocki);
end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = clearAnalogChannels(vr);
[vr,sessionData] = collectTrialData(vr);
%vr = makeTMazeFigs(vr,sessionData);
