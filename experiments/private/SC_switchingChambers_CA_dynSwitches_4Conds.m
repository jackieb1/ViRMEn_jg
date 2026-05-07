function code = SC_switchingChambers_CA_dynSwitches_4Conds_Cam
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
vr = makeDirSNC_CA(vr);

% set parameters
vr.feedbackDelay = eval(vr.exper.variables.feedbackDelay);
vr.rewardDelay = eval(vr.exper.variables.rewardDelay);
vr.friction = 0.25; % changed setting for debugging VR
vr.itiCorrect = eval(vr.exper.variables.itiCorrect); 
vr.itiMissBase = eval(vr.exper.variables.itiMissBase); 
%vr.penaltyITI = 0; 
%vr.penaltyProb = eval(vr.exper.variables.penaltyProb);

floorLength = eval(vr.exper.variables.floorLength);
funnelLength = eval(vr.exper.variables.funnelLength);
vr.funnelWidth = eval(vr.exper.variables.funnelWidth);
vr.hideCuePast = eval(vr.exper.variables.hideCuePast);
vr.rewardLength = 5 + floorLength + funnelLength;
vr.alpha = eval(vr.exper.variables.alpha_mov);

vr.fractionNoChecker = eval(vr.exper.variables.fractionNoChecker);
vr.fractionAngledGrating = eval(vr.exper.variables.fractionAngledGrating);

vr.nWorlds = length(vr.worlds);

% vr.sessionSwitchpoints = eval(vr.exper.variables.switches);
% introduce switches dynamically depending on performance of mouse:
% set a minimum block size, window size, and fraction correct for window to
% introduce a switch
vr.minBlockSize = eval(vr.exper.variables.minBlockSize_Switch);
vr.minFrac_Corr_4Switch = eval(vr.exper.variables.fractionCorrect_Switch);
vr.minWindow_4Switch = eval(vr.exper.variables.minWindow_Switch);
vr.Rewards = [];
vr.Switches = [];

% initBlock = 2 - mod(vr.mouseNum,2);
initBlock = eval(vr.exper.variables.initBlock); % sets the initial block
vr.switchBlock = initBlock; % added by CA

% General setup functions
vr = initDAQ(vr);
vr = initCounters(vr);
vr.contingentBlocks = [1,2; 3,4]; % CA

% Identify indices for cue target walls (for hiding)
vr = getHidingTargetVertices_4Conds(vr);

% Choose the first world
worldChoice = randi(size(vr.contingentBlocks,2));

vr.currentWorld = vr.contingentBlocks(initBlock,worldChoice); % CA modified

% choose an angled grating or a non-checker trial probabilistically
rand_checker = rand;
rand_grating = rand;
if rand_checker < vr.fractionNoChecker
    vr.currentWorld = vr.currentWorld + 4;
end
if rand_grating < vr.fractionAngledGrating
   vr.currentWorld = vr.currentWorld +  8;
end

% outputSingleScan(vr.aoSync,-5);
%vr.SyncState = 1;

vr = initStepperMotor(vr); % initialise the stepper motor for syringe pump reward delivery 
vr = initCamera_hardwareTrigger(vr); % initialise the camera for pupillometry

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)    

% if vr.SyncState == 1
%     outputSingleScan(vr.aoSync,5);
%     vr.SyncState = 0;
% else
%     outputSingleScan(vr.aoSync,0);
%     vr.SyncState = 1;
% end

% trigger the camera 
triggerCamera(vr);
%trigger(vr.vid);

% collect behavior data
% vr = collectBehaviorIter(vr);
vr = collectBehaviorIter_full(vr);

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
        rightWorld = ismember(vr.currentWorld, [1,4,5,8,9,12,13,16]);
        %rightWorld = vr.currentWorld==1 || vr.currentWorld==4 || vr.currentWorld==5 || vr.currentWorld==8;
        rightArm = vr.position(1) > 0;
        if ~abs(rightWorld-rightArm)
            %deliver reward if appropriate
            vr.behaviorData(9,vr.trialIterations) = 1;
            vr.numRewards = vr.numRewards + 1;
            vr = giveReward_stepperMotor(vr,1,vr.sm);
            vr.Rewards = [vr.Rewards 1]; % append the vector containing binary reward info per trial
            vr.itiDur = vr.itiCorrect;
            vr.wrongStreak = 0;
        else
            % update wrongStreak counter if incorrect
            vr.behaviorData(9,vr.trialIterations) = 0;
            %vr.itiMiss = vr.itiMissBase + vr.penaltyITI*vr.wrongStreak;
            vr.itiMiss = vr.itiMissBase; % CA
            vr.itiDur = vr.itiMiss;
            vr.wrongStreak = vr.wrongStreak + 1;
            vr.Rewards = [vr.Rewards 0]; % append the vector containing binary reward info per trial
        end
        % End trial and update switchBlock / worlds info
        vr = endVRTrial_CA(vr);
         
        % check if switch is appropriate and if so, introduce switch
        vr = dynamicSwitching_CA(vr);

        vr.blockWorlds = vr.contingentBlocks(vr.switchBlock,:);
        
        % Change to noChecker maze & angled maze probabilistically
        rand_checker = rand;
        rand_grating = rand;
        if rand_checker < vr.fractionNoChecker
            vr.blockWorlds = vr.blockWorlds + 4;
        end
        if rand_grating < vr.fractionAngledGrating
            vr.blockWorlds = vr.blockWorlds +  8;
        end
        
    else
        vr.behaviorData(9,vr.trialIterations) = 0;
        vr.behaviorData(8,vr.trialIterations) = -1;
    end
else
    vr.behaviorData(9,vr.trialIterations) = 0;
end

% Check if position is past hide-point
if (ismember(vr.currentWorld, [5:8, 13:16])) && ~vr.targetRevealed && (vr.position(2) > vr.hideCuePast) && ~vr.inITI
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

vr = waitForNextTrial_CA(vr);

% Update Textboxes
vr = printText2CommandLine(vr);


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)

if ~vr.debugMode
    stop(vr.ai),
    delete(vr.ai),
    delete(vr.ao),
    [vr,sessionData] = collectTrialData(vr);
    
    % exit the camera acquisition mode
    stop(vr.vid);
%     try
%         vr = makeSwitchingSessionFigs(vr,sessionData, vr.sessionSwitchpoints);
%     catch
%         warning('Unable to make Figures'),
%     end
end
