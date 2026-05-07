function code = T_maze_Cue123_photostimCue3_wholeTrial
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
vr.currentWorld = randsample([1 2], 1); % Photostim not on first trial so choose one of first two cues
vr.biasCorrection = false;
vr = initDAQ(vr);
vr = initLivePlots(vr);

vr.stimTrialSegment = 'wholeTrial';
vr.isStimTrial = 0;
vr.stimOn = 0;
vr.stimStarted = 0;
vr.stimRampTime = 0.5;
vr.maxStimOnTime = 30;
vr.numTimeOuts = 0;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
if isTrialStart(vr)
%     vr = updateLivePlots(vr);
    vr = initTrial(vr);
    vr.isStimTrial = vr.nextTrialIsStim;
end

vr = checkExecuteStim_timeOut(vr);
vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze(vr, vr.isStimTrial, vr.stimOn);
vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
vr = checkforTrialEndPosition_Tmaze(vr);
vr = waitForNextTrial(vr);
% vr.nextWorld = 3; % for testing
if vr.inITI && (vr.nextWorld == 3)
    vr.nextTrialIsStim = 1;
else
    vr.nextTrialIsStim = 0;
end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats(vr);
vr = updateLivePlots(vr);
text(0, -7, ['Time outs: ' num2str(vr.numTimeOuts)])
savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
vr = clearAnalogChannels(vr);



