function code = SC_switchingChambers_CA_dynSwitches_4Conds_photoInhib_Rig2
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

% set directory for data to be stored in 
vr = makeDirSNC_CA_Camera_Rig2(vr);
%vr = makeDirSNC_CA_Rig2(vr);

% evaluate background RBG values
vr.backgroundR_val = eval(vr.exper.variables.backgroundR_val);
vr.backgroundG_val = eval(vr.exper.variables.backgroundG_val);
vr.backgroundB_val = eval(vr.exper.variables.backgroundB_val);

% evaluate maze geometry parameters  //////////////
vr.floorLength = eval(vr.exper.variables.floorLength);
vr.funnelLength = eval(vr.exper.variables.funnelLength);
vr.funnelWidth = eval(vr.exper.variables.funnelWidth);
vr.hideCuePast = vr.floorLength + vr.funnelLength + 5;
vr.rewardLength = vr.floorLength + vr.funnelLength + 5;
vr = getHidingTargetVertices_4Conds(vr); % Identify indices for cue target walls (for hiding)
% evaluate timing parameters
vr.feedbackDelay = eval(vr.exper.variables.feedbackDelay);
vr.rewardDelay = eval(vr.exper.variables.rewardDelay);
vr.itiCorrect = eval(vr.exper.variables.itiCorrect); 
vr.itiMissBase = eval(vr.exper.variables.itiMissBase); 

%vr.penaltyITI = 0; 
%vr.penaltyProb = eval(vr.exper.variables.penaltyProb);

% evaluate and set parameters for movement and friction
vr.alpha = eval(vr.exper.variables.alpha_mov);
vr.friction = 0.25;

% evaluate parameters for switching logic ///////////
vr.nWorlds = length(vr.worlds);
vr.contingentBlocks = [1,2; 3,4]; % CA
vr.fractionNoChecker = eval(vr.exper.variables.fractionNoChecker);
% introduce switches dynamically depending on performance of mouse:
% set a minimum block size, window size, and fraction correct for window to
% introduce a switch
vr.minBlockSize = eval(vr.exper.variables.minBlockSize_Switch);
vr.minFrac_Corr_4Switch = eval(vr.exper.variables.fractionCorrect_Switch);
vr.minWindow_4Switch = eval(vr.exper.variables.minWindow_Switch);
vr.Rewards = []; % vector to keep track of Rewards and Switches
vr.Switches = []; % keep track of block switches
vr.RuleSwitches = []; % keep track of rule switches
initBlock = eval(vr.exper.variables.initBlock); % sets the initial block
% initBlock = 2 - mod(vr.mouseNum,2); % alternative: 1st block random
vr.switchBlock = initBlock; 

% Choose the first world
worldChoice = randi(size(vr.contingentBlocks,2));
vr.currentWorld = vr.contingentBlocks(initBlock,worldChoice); % CA modified

% choose an angled grating or a non-checker trial probabilistically ///////
vr.fractionAngledGrating = eval(vr.exper.variables.fractionAngledGrating);
rand_checker = rand;
rand_grating = rand;
if rand_checker < vr.fractionNoChecker
    vr.currentWorld = vr.currentWorld + 4;
end
if rand_grating < vr.fractionAngledGrating
   vr.currentWorld = vr.currentWorld +  8;
end

% evaluate parameters for photoinhibition ////// 
vr.inhibBlock_size = eval(vr.exper.variables.blockSize_Inhib); % set the size of a block with a certain fraction of inhibition trials
vr.frac_inhibTrials = eval(vr.exper.variables.frac_inhibTrials); 
vr.segment_inhib = eval(vr.exper.variables.segment_inhib); % this will be a string, either 'stimulus' or 'feedback'

vr.ind_trials2inhibit = []; % start with empty vector of trials2inhibit, as that will depend on performance, i.e. when mouse reaches criterion
vr.block_ID = []; % will be a vector that keeps track of which overall blockID current trial or fame has
vr.PhotoStimInfo = 0; % PhotoStimInfo to record in Virmen behavior file
vr.PhotoStimBlock = false; % indicating whether current block is a PhotoStimBlock or not

% General setup functions ///////
%vr = initDAQ(vr);
vr = initDAQ_Cam_Photostim(vr);
vr = initCounters(vr); % initialize counters for number of trials, rewards etc

% outputSingleScan(vr.aoSync,-5);
%vr.SyncState = 1;

%vr = initStepperMotor(vr); % initialise the stepper motor for syringe pump reward delivery 
%vr = initCamera_Rig2(vr); % initialise the camera for pupillometry
vr = initCamera_hardwareTrigger_Rig2(vr);
vr = init_lickWindow(vr); % set up an additional window that will display the lick info

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)    

% if vr.SyncState == 1
%     outputSingleScan(vr.aoSync,5);
%     vr.SyncState = 0;
% else
%     outputSingleScan(vr.aoSync,0);
%     vr.SyncState = 1;
% end

% update lick info plot
vr = display_licks(vr);

% trigger the camera 
vr = triggerCamera(vr);

% collect behavior data
vr = collectBehaviorIter_PhotoStim(vr);

% Decrease velocity by friction coefficient (can be zero)
vr = adjustFriction(vr);

% check if swichting conditions are met and introduce block switch / Photostim
% block / rule switch if appropriate
vr = checkSwitch_Condition(vr);
% check if photostimulation conditions are met and trigger
% stimulation if so
vr = checkPhotostim_Condition_new(vr);

% check for trial-terminating position and deliver reward
if vr.inITI == 0 && (vr.position(2) >= vr.rewardLength)
    % Disable movement
    vr.dp = 0*vr.dp;
    % Enforce Reward Delay
    if ~vr.inRewardZone
        vr.rewStartTime = tic;
        vr.inRewardZone = 1;
        vr.hasFeedback = 0;
        vr.position(1:2) = [sign(vr.position(1))*vr.funnelWidth/4, vr.rewardLength]; % fix the mouse's position
    end
    vr.rewDelayTime = toc(vr.rewStartTime);   
    if ~vr.hasFeedback && vr.rewDelayTime > vr.feedbackDelay % only show feedback after delay (time between past maze end and feedback onset)
        % feedback will be present while reward delay not reached yet
        vr.hasFeedback = 1;
        vr.position(2) = vr.rewardLength + 1e-3;
        vr.behaviorData(8,vr.trialIterations) = -2;
        vr.behaviorData(9,vr.trialIterations) = 0;
    elseif vr.rewDelayTime > vr.rewardDelay % give reward after reward delay (time between past maze end reward onset)
        % Check reward condition
        rightWorld = ismember(vr.currentWorld, [1,4,5,8,9,12,13,16]);
        rightArm = vr.position(1) > 0;
        if ~abs(rightWorld-rightArm)
            %deliver reward if appropriate
            vr.behaviorData(9,vr.trialIterations) = 1;
            vr.numRewards = vr.numRewards + 1;
            vr = giveReward(vr,1);
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
vr = waitForNextTrial_CA_Rig2(vr);

% Update Textboxes
vr = printText2CommandLine_PhotoStim(vr);


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
