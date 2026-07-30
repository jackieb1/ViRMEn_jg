function code = wideLinearTrack_friction05_ITI
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
    vr.rewardYLocation = eval(vr.exper.variables.towerYLocation);
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
    vr.towerPopupLocation = vr.rewardYLocation - vr.rewardZoneRadius;
    vr.currentWorld = vr.worldBlock;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

    % Loop maze
    if isTrialStart(vr)
        vr = updateLivePlots_wideLinearTrack(vr);
        vr.nextWorld = vr.worldBlock;
        vr = initTrial(vr);
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
    vr = collectBehaviorIter_TMaze(vr);
    vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
    vr = checkforTrialEndPosition_wideLinearTrack(vr);
    vr = waitForNextTrial(vr);

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
    savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
    saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
    vr = clearAnalogChannels(vr);
    if vr.numTrials > 0
        [vr,sessionData] = collectTrialData(vr);
    end
    printSessionStats_wideLinearTrack(vr);
