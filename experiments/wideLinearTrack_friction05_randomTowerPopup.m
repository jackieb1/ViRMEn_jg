function code = wideLinearTrack_friction05_randomTowerPopup
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
    vr.rewardXLocation = 0;
    vr.rewardYLocation = 200;
    vr.rewardZoneRadius = 3;
    vr.teleportYLocation = vr.rewardYLocation + 5;
    vr.startYLocation = 2;
    vr.wallPatternRepetitionLength = eval(vr.exper.variables.wallPatternRepetitionLength);
    vr.correctTrials = [];
    vr.previousVelocity = [0 0 0 0];
%     vr.exper.variables.startYLocation = vr.startYLocation;
    vr.frictionDecay = 0.05;
    vr.dpGain = 1;
    vr.sideOffset = 0;
    
    % Tower popup
    vr.worldTowerReveal = 2;
    vr.towerPopupLocation = eval(vr.exper.variables.towerYLocation) - 20;
%     vr.blockLength = 50;
%     vr.blockTrial = 1;
    vr.errorProbability = 0.2;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    if vr.numRewards >= vr.maxNumRewards
        vr.experimentEnded = true;
    end

    % Loop maze
    if vr.position(2) > vr.teleportYLocation
        vr.currentWorld = 1;
        vr.trialEnded = 1;
        vr.numTrials = vr.numTrials + 1;
        vr.position(2) = mod(vr.position(2), vr.wallPatternRepetitionLength);
        vr.trialTimeTrials = [vr.trialTimeTrials toc(vr.trialTimer)];
        vr.trialTimer = tic;
        vr.correctTrials = [vr.correctTrials vr.numRewardsThisTrial];
        vr.numRewardsThisTrial = 0;
        vr = saveTrialData(vr);
        vr = updateLivePlots_wideLinearTrack(vr);
        
        vr.worldTowerReveal = randsample([2 3 4], 1, true, [0.8 0.1 0.1]);
        if vr.worldTowerReveal == 2
            vr.rewardXLocation = 0;
        elseif vr.worldTowerReveal == 3
            vr.rewardXLocation = -5;
        elseif vr.worldTowerReveal == 4
            vr.rewardXLocation = 5;
        end
        disp(vr.worldTowerReveal)
        
    end
    
    if vr.position(2) > vr.towerPopupLocation
        vr.currentWorld = vr.worldTowerReveal;
    end
    
    % Friction along walls
    if vr.collision
        vr.dpGain = vr.dpGain * (1-vr.frictionDecay);
    else
        vr.dpGain = vr.dpGain * (1+vr.frictionDecay);
    end
    vr.dpGain = min(vr.dpGain, 1); % cap at 1
    vr.dpGain = max(vr.dpGain, 0.01); % cap at 1
    vr.dp(2) = vr.dp(2) * vr.dpGain;

    vr = outputVirmenTrigger(vr);
    vr = collectBehaviorIter_TMaze(vr, vr.worldTowerReveal);
    vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
    
    % Delivery reward if in reward zone
    vr.distToRewardZone = hypot(vr.position(1)-vr.rewardXLocation, vr.position(2)-vr.rewardYLocation);
    if (vr.distToRewardZone < vr.rewardZoneRadius) && (vr.numRewardsThisTrial < vr.numRewardsPerTrial)
        vr = giveRecordProbReward(vr, vr.correctRewardProbability);
        vr.numRewardsThisTrial = vr.numRewardsThisTrial + 1;
    end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
    savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
    saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
    vr = clearAnalogChannels(vr);
    if vr.numTrials > 0
        [vr,sessionData] = collectTrialData(vr);
    end
    printSessionStats_wideLinearTrack(vr);
