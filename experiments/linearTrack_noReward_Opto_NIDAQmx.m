function code = linearTrack_noReward_Opto_NIDAQmx
% linearTrackNew   Code for the ViRMEn experiment linearTrackNew.
%   code = linearTrackNew   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT


%% MAZE DESCRIPTION
% Infinite linear maze (loops back on itself) with 4 wall cues and
% associated landmarks.

% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)

    % wrap world
    vr.mazeLength = eval(vr.exper.variables.mazewidth);
    vr = wrapLinearWorlds(vr);
    
    % Initialize VR
    vr.debugMode = false;
    vr.ops = getRigInfo();
    vr = makeVirmenDir(vr);
    vr = initLinearTrack(vr);
    resetNIDAQmx; % reset PFI0
    vr = initDAQ(vr);
    vr = initLivePlots_linearMaze(vr);
    
    % Initialize maze
    vr.rewardLocation = 350;
    
    vr.optoOn = 0;
    vr.optoTimeOn = 0;
    vr.optoDur = 4.5;
    vr.optoITI = tic;
    vr.optoITIDur = 30;
    vr.optoNum = zeros(6, 1); % counter for each power level
    
    % 7.5 Hz train for 4.5s
    vr.vIdx = randsample(6,1);
    vr.vHigh = vr.vIdx*0.5 + 2; % pulse amp V
    vr.pulse_ms = 30; % pulse dur ms
    vr.pulse_freq = 4.5; % Hz
    vr.Rate = 1e3;
    vr.yPulse = makePulseTrain(vr.Rate, 7.5, 0.03, 4.5, vr.vHigh);
    
    vr = setupAO_PFI0(vr);

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % Loop maze
    if vr.position(2) > vr.mazeLength
        vr = endLinearTrackTrial(vr);
        vr = initLinearTrackTrial(vr);
        vr.currentWorld = randsample(vr.worldsAvailable, 1, true, vr.worldProbability);
        vr = updateLivePlots_linearMaze(vr);
    end

    vr = outputVirmenTrigger(vr);
    vr = collectBehaviorIter_TMaze(vr, vr.optoOn, vr.vHigh);
    vr = optoNIDAQmx(vr);
    vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)

vr = updateLivePlots_linearMaze(vr);
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats_linearMaze(vr)
delete(instrfind);
releaseAO(vr);
resetNIDAQmx;