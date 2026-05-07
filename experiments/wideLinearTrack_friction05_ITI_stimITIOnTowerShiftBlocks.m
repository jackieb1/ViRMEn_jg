function code = wideLinearTrack_friction05_ITI_stimITIOnTowerShiftBlocks
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
    vr.blockLength = 50;
    vr.worldBlock = 2;
    vr.towerPopupLocation = vr.rewardYLocation - vr.rewardZoneRadius*2;
    
    vr.blockTrial = 1;
    vr.currentWorld = vr.worldBlock;
    vr.optoOn = 0;
    vr.switchPerformanceThreshold = 0.8;
    vr.switchPerformanceWindowTrials = 30;
    vr.isControlBlock = true;
    vr.numBlockSwitches = 0;
    vr.stimWasOn = false;
    vr.stimTime = vr.itiCorrect-0.1;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

    % Loop maze
    if isTrialStart(vr)
        vr = updateLivePlots_wideLinearTrack(vr);
        
        vr.stimWasOn = false;
        vr.optoOn = 0;
        % Define tower location for current block
        vr.blockTrial = vr.blockTrial + 1;
        if length(vr.correctTrials)>vr.switchPerformanceWindowTrials
            vr.trailingAccuracy = mean(vr.correctTrials(end-vr.switchPerformanceWindowTrials:end));
            vr.performanceCheck = vr.trailingAccuracy > vr.switchPerformanceThreshold;
            vr.finishedBlock = vr.blockTrial > vr.blockLength;
            if vr.isControlBlock && vr.finishedBlock && vr.performanceCheck
                vr.blockTrial = 1;
                vr.worldBlock = randsample([3 4], 1);
                vr.isControlBlock = false;
            elseif (vr.isControlBlock==false) && vr.finishedBlock
                vr.blockTrial = 1;
                vr.worldBlock = 2;
                vr.isControlBlock = true;
                vr.numBlockSwitches = vr.numBlockSwitches + 1;
            end
        end
        disp(vr.worldBlock)
        
        % Adjust reward location
        if vr.worldBlock == 2
            vr.rewardXLocation = 0;
        elseif vr.worldBlock == 3
            vr.rewardXLocation = -5;
        elseif vr.worldBlock == 4
            vr.rewardXLocation = 5;
        end

        % Set world start
        vr.nextWorld = vr.worldBlock;
        vr = initTrial(vr);
        vr.optoOn = 0;
        
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
    
    if (vr.isControlBlock==false)
        if (vr.position(2) > vr.towerPopupLocation) && (vr.stimWasOn == 0)
            vr.stimStartTime = tic;
            vr.stimWasOn = true;
        end

        if vr.stimWasOn && (toc(vr.stimStartTime) < vr.stimTime)
            vr.optoOn = 1;
        else
            vr.optoOn = 0;
        end
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
    vr = clearAnalogChannels(vr);
    if vr.numTrials > 0
        [vr,sessionData] = collectTrialData(vr);
    end
    printSessionStats_wideLinearTrack(vr);
    stats = fprintf('Number of block switches: %d\n', vr.numBlockSwitches);
