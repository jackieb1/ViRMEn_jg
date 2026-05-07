function code = SC_switchingChambers_revealTarget_feedbackDelay
% Linear Track   Code for the ViRMEn experiment Linear Track.
%   code = Linear Track   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT



% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)

vr.debugMode = false;
vr = makeDirSNC(vr);

% set parameters
vr.feedbackDelay = eval(vr.exper.variables.feedbackDelay);
vr.rewardDelay = eval(vr.exper.variables.rewardDelay);
vr.mvThresh = eval(vr.exper.variables.mvThresh);
vr.friction = 0;
vr.itiCorrect = eval(vr.exper.variables.itiCorrect); 
vr.itiMissBase = eval(vr.exper.variables.itiMissBase); 
vr.penaltyITI = 0; 
vr.penaltyProb = eval(vr.exper.variables.penaltyProb);
floorLength = eval(vr.exper.variables.floorLength);
funnelLength = eval(vr.exper.variables.funnelLength);
vr.rewardLength = 5 + floorLength + funnelLength;
vr.nWorlds = length(vr.worlds);
vr.sessionSwitchpoints = eval(vr.exper.variables.switches);
vr.fractionNoChecker = eval(vr.exper.variables.fractionNoChecker);
vr.hideCuePast = eval(vr.exper.variables.hideCuePast);
vr.funnelWidth = eval(vr.exper.variables.funnelWidth);
% initBlock = 2 - mod(vr.mouseNum,2);
initBlock = eval(vr.exper.variables.initBlock);

% General setup functions
vr = initTextboxes(vr);
vr = initDAQ(vr);
vr = initCounters(vr);
vr = createBlockStructure(vr,initBlock);

% Identify indices for cue target walls (for hiding)
vr = getHidingTargetVertices(vr);

% Choose the first world
worldChoice = randi(size(vr.contingentBlocks,2));
vr.currentWorld = vr.contingentBlocks(1,worldChoice);
if rand < vr.fractionNoChecker
    vr.currentWorld = vr.currentWorld + 4;
end

outputSingleScan(vr.aoSync,-5);
vr.SyncState = 1;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

if vr.SyncState == 1
    outputSingleScan(vr.aoSync,5);
    vr.SyncState = 0;
else
    outputSingleScan(vr.aoSync,0);
    vr.SyncState = 1;
end

% collect behavior data
vr = collectBehaviorIter(vr);

% Decrease velocity by friction coefficient (can be zero)
vr = adjustFriction(vr);

% check for trial-terminating position and deliver reward
if vr.inITI == 0 && (vr.position(2) >= vr.rewardLength)
    % Disable movement
    vr.dp = 0*vr.dp;
    % Enforce Reward Delay
    if ~vr.inRewardZone
        vr.rewStartTime = tic;
        vr.inRewardZone = 1;
        vr.hasFeedback = 0;
        vr.position(1:2) = [sign(vr.position(1))*vr.funnelWidth/4, vr.rewardLength];
    end
    vr.rewDelayTime = toc(vr.rewStartTime);   
    if ~vr.hasFeedback && vr.rewDelayTime > vr.feedbackDelay
        vr.hasFeedback = 1;
        vr.position(2) = vr.rewardLength + 1e-3;
        vr.behaviorData(8,vr.trialIterations) = -2;
        vr.behaviorData(9,vr.trialIterations) = 0;
    elseif vr.rewDelayTime > vr.rewardDelay
        % Check reward condition
        rightWorld = vr.currentWorld==1 || vr.currentWorld==4 || vr.currentWorld==5 || vr.currentWorld==8;
        rightArm = vr.position(1) > 0;
        if ~abs(rightWorld-rightArm)
            %deliver reward if appropriate
            vr.behaviorData(9,vr.trialIterations) = 1;
            vr.numRewards = vr.numRewards + 1;
            vr = giveReward(vr,1);
            vr.itiDur = vr.itiCorrect;
            vr.wrongStreak = 0;
        else
            % update wrongStreak counter if incorrect
            vr.behaviorData(9,vr.trialIterations) = 0;
            vr.itiMiss = vr.itiMissBase + vr.penaltyITI*vr.wrongStreak;
            vr.itiDur = vr.itiMiss;
            vr.wrongStreak = vr.wrongStreak + 1;
        end
        % End trial and update switchBlock / worlds info
        vr = endVRTrial(vr);
        switchBlock = 1 + find(vr.numTrials >= vr.sessionSwitchpoints,1,'last');
        if isempty(switchBlock)
            switchBlock = 1;
        end
        vr.blockWorlds = vr.contingentBlocks(switchBlock,:);
        % Change to noChecker maze probabilistically
        if (sum(vr.numTrials == vr.sessionSwitchpoints) || rand < vr.fractionNoChecker) ...
                && vr.fractionNoChecker ~=0
            vr.blockWorlds = vr.blockWorlds + 4;
        end
    else
        vr.behaviorData(9,vr.trialIterations) = 0;
        vr.behaviorData(8,vr.trialIterations) = -1;
    end
else
    vr.behaviorData(9,vr.trialIterations) = 0;
end

% Check is position is past hide-point
if (vr.currentWorld > 4) && ~vr.targetRevealed && (vr.position(2) > vr.hideCuePast) && ~vr.inITI
    vr.targetRevealed = 1;
    % Hide cue walls in target zone
    vr.worlds{vr.currentWorld}.surface.vertices(2,vr.cueToHide{vr.currentWorld}) = ...
        100 + vr.worlds{vr.currentWorld}.surface.vertices(2,vr.cueToHide{vr.currentWorld});
    vr.worlds{vr.currentWorld}.surface.vertices(2,vr.blankToHide{vr.currentWorld}) = ...
        -100 + vr.worlds{vr.currentWorld}.surface.vertices(2,vr.blankToHide{vr.currentWorld});
elseif vr.targetRevealed && vr.inITI
    vr.targetRevealed = 0;
    % Reset / reveal cue ID once in reward zone
    vr.worlds{vr.currentWorld}.surface.vertices(2,vr.cueToHide{vr.currentWorld}) = ...
        -100 + vr.worlds{vr.currentWorld}.surface.vertices(2,vr.cueToHide{vr.currentWorld});
    vr.worlds{vr.currentWorld}.surface.vertices(2,vr.blankToHide{vr.currentWorld}) = ...
        100 + vr.worlds{vr.currentWorld}.surface.vertices(2,vr.blankToHide{vr.currentWorld});
end

% Check to see if ITI has elapsed, and restart trial if it has
vr = waitForNextTrial(vr);

% Update Textboxes
vr = updateTextDisplay(vr);

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
if ~vr.debugMode
    stop(vr.ai),
    delete(vr.ai),
    delete(vr.ao),
    [vr,sessionData] = collectTrialData(vr);
    try
        vr = makeSwitchingSessionFigs(vr,sessionData, vr.sessionSwitchpoints);
    catch
        warning('Unable to make Figures'),
    end
end
