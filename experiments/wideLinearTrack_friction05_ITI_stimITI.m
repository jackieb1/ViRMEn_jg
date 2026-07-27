function code = wideLinearTrack_friction05_ITI_centerLeftTowerBlocks_stimITI
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

    % wrap world
%     vr.mazeLength = eval(vr.exper.variables.boxLength);
%     vr = wrapLinearWorlds(vr);
    
    % Initialize VR
    vr.debugMode = false;
    vr.ops = getRigInfo();
    vr = makeVirmenDir(vr);
    vr = initDAQ(vr);
    vr = initLivePlots_wideLinearTrack(vr);
    
    % Initialize maze
    vr = initLinearTrack(vr);
    vr = initLinearTrack(vr);
    vr.rewardXLocation = 0;
    vr.rewardYLocation = 100;
    vr.rewardZoneRadius = 2.5;
%     vr.teleportYLocation = vr.rewardYLocation + 5;
%     vr.startYLocation = 2;
%     vr.wallPatternRepetitionLength = eval(vr.exper.variables.wallPatternRepetitionLength);
    vr.correctTrials = [];
    vr.previousVelocity = [0 0 0 0];
%     vr.exper.variables.startYLocation = vr.startYLocation;
    vr.frictionDecay = 0.05;
    vr.dpGain = 1;
    vr.sideOffset = 0;
    vr.inRewardZone = 0;
    vr.itiCorrect = 3;  
    vr.itiMiss = 7;
    vr.rewardDelay = 0.5;
    vr.backgroundR_val = 0;
    vr.backgroundG_val = 0;
    vr.backgroundB_val = 0;
    
    % Tower popup
    vr.worldBlock = 2;
    vr.towerPopupLocation = vr.rewardYLocation - vr.rewardZoneRadius*2;
    vr.currentWorld = vr.worldBlock;
    vr.optoOn = 0;
    vr.stimTime = vr.itiCorrect;
    vr.stimWasOn = false;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

    % Loop maze
    if isTrialStart(vr)
        vr = updateLivePlots_wideLinearTrack(vr);

        % Set world start
        vr.nextWorld = vr.worldBlock;
        vr = initTrial(vr);
        vr.optoOn = 0;
        vr.stimWasOn = false;
    end
    
    % Friction if running on the walls
    if vr.collision
        vr.dpGain = vr.dpGain * (1-vr.frictionDecay);
    else
        vr.dpGain = vr.dpGain * (1+vr.frictionDecay);
    end
    vr.dpGain = min(vr.dpGain, 1); % cap at 1
    vr.dpGain = max(vr.dpGain, 0.01); % cap at 1
    vr.dp(2) = vr.dp(2) * vr.dpGain;
    
    % Standard maze iterations
    vr = outputVirmenTrigger(vr);
    vr = collectBehaviorIter_TMaze(vr, vr.optoOn);
    vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
    vr = checkforTrialEndPosition_wideLinearTrack(vr);
    vr = waitForNextTrial(vr);

    if (vr.position(2) > vr.towerPopupLocation) && (vr.stimWasOn == 0)
        vr.stimStartTime = tic;
        vr.stimWasOn = true;
    end

    if vr.stimWasOn && (toc(vr.stimStartTime) < vr.stimTime)
        vr.optoOn = 1;
    else
        vr.optoOn = 0;
    end

    if vr.optoOn
        vr.ao.outputSingleScan(5);
    else
        vr.ao.outputSingleScan(0);
    end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
    vr.ao.outputSingleScan(0);
    savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
    saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
    vr = writePerformanceToExcel(vr);
    vr = clearAnalogChannels(vr);
    if vr.numTrials > 0
        [vr,sessionData] = collectTrialData(vr);
    end
    printSessionStats_wideLinearTrack(vr);
