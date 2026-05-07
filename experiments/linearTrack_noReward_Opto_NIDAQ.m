function code = linearTrack_noReward_Opto_NIDAQ
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
    vr = initDAQ(vr);
    vr = initLivePlots_linearMaze(vr);
    
    % Initialize maze
    vr.rewardLocation = 350;
    
    vr.optoOn = 0;
    vr.optoLocation = 200;
    vr.optoTimeOn = 0;
    vr.optoDur = 4.5;
    vr.optoITI = tic;
    vr.optoITIDur = 30;
    vr.optoNum = zeros(6, 1); % counter for each power level
    
    vr.vIdx = 0;
    vr.vHigh = 0;
    vr.pulse_ms = 25;
    vr.post_ms = 5;
    vr.Rate = 1e3;
    vr.nHigh=round(vr.pulse_ms/1000*vr.Rate);
    vr.nPost=round(vr.post_ms/1000*vr.Rate);
    vr.yPulse = [vr.vHigh*ones(vr.nHigh,1); zeros(vr.nPost,1)];
    
    vr = setupAO_PFI0(vr);

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % Loop maze
    if vr.position(2) > vr.mazeLength
        vr = endLinearTrackTrial(vr);
        vr = initLinearTrackTrial(vr);
        vr.currentWorld = randsample(vr.worldsAvailable, 1, true, vr.worldProbability);
        vr = updateLivePlots_linearMaze(vr);
        vr.vIdx = randsample(6, 1);
        vr.vHigh = vr.vIdx*0.5 + 2; % Voltage between 2.5-5V
        vr.yPulse = [vr.vHigh*ones(vr.nHigh,1); zeros(vr.nPost,1)]; % set new pulse voltage
        vr.aoEnable(vr, false);
        vr.writer.WriteMultiSample(true, single(vr.yPulse(:)).');     % re-arm; waits for PFI0
        disp(['New voltage set to: ' num2str(vr.vHigh)]);
    end

    vr = outputVirmenTrigger(vr);
    vr = collectBehaviorIter_TMaze(vr, vr.optoOn);
    vr = posTriggerOptoNIDAQ(vr);
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