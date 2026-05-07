
 function code = SC_linearTrack_CA_Rig2
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
vr = makeDirSNC_CA_Rig2(vr); % creates a directory to store data to

% evaluate background color
vr.backgroundR_val = vr.exper.variables.backgroundR_val;
vr.backgroundG_val = vr.backgroundR_val;
vr.backgroundB_val = vr.backgroundR_val;

% set parameters
vr.alpha = eval(vr.exper.variables.alpha_mov);
vr.rewardDelay = 1; % delay of 1s from reward zone entry until reward trigger
vr.mvThresh = 15;   %?
vr.friction = 0.8;  % value adjust friction in collisions
vr.itiCorrect = 1;  
vr.itiMiss = 0;
vr.mazeLength = eval(vr.exper.variables.floorLength);
vr.nWorlds = length(vr.worlds);

%vr = initTextboxes(vr); % not working, bug in current Matlab version
vr = initDAQ(vr);
vr = initCounters(vr);  
vr.currentWorld = randi(vr.nWorlds); % randomly choose one of the available worlds

% vr = initStepperMotor(vr); % initialise the stepper motor for syringe pump reward delivery 


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

% collect behavior data
vr = collectBehaviorIter_LinTrack(vr);

% Decrease velocity by friction coefficient (can be zero)
vr = adjustFriction(vr);

% Deliver reward if 'r' key pressed
manualReward = vr.keyPressed == 82; %'r' key
if manualReward
    vr.behaviorData(9,vr.trialIterations) = 1;
    vr.numRewards = vr.numRewards + 1;
    vr = giveReward(vr,1);
end

% check for trial-terminating position and deliver reward
if vr.inITI == 0 && (vr.position(2) > vr.mazeLength + 5)
    % Disable movement
    vr.dp = 0*vr.dp;
    % Enforce Reward Delay
    if ~vr.inRewardZone
        vr.rewStartTime = tic;
        vr.inRewardZone = 1;
    end
    vr.rewDelayTime = toc(vr.rewStartTime);    
    if vr.rewDelayTime > vr.rewardDelay   
        vr.behaviorData(9,vr.trialIterations) = 1;
        vr.numRewards = vr.numRewards + 1;
        vr = giveReward(vr,1);
        vr.itiDur = vr.itiCorrect;
        vr = endVRTrial(vr);
    else
        vr.behaviorData(9,vr.trialIterations) = 0;
        vr.behaviorData(8,vr.trialIterations) = -1;
    end
else
    vr.behaviorData(9,vr.trialIterations) = 0;
end

% Check to see if ITI has elapsed, and restart trial if it has
vr = waitForNextTrial_CA_Rig2(vr);

% Update Textboxes: text boxes in VR window not working with new MATLAB version, so print to command line instead
% vr = updateTextDisplay(vr); 
vr = printText2CommandLine_LinTrack(vr);

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
if ~vr.debugMode
    stop(vr.ai),
    delete(vr.ai),
    delete(vr.ao),
end
[vr,sessionData] = collectTrialData(vr);
vr = makeLinearTrackFigs(vr,sessionData);
