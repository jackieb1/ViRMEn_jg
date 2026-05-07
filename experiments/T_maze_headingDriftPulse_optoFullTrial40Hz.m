function code = T_maze_headingDriftPulse_optoFullTrial40Hz
% T_maze   Code for the ViRMEn experiment T_maze.
%   code = T_maze   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT

% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)
vr.debugMode = false;
vr.ops = getRigInfo();
vr = makeVirmenDir(vr);
vr = initTMaze(vr);
vr = initDAQ(vr);
vr = initLivePlots(vr);

% Heading pulse parameters
vr.driftYTrigger = 150;
vr.inDriftPulse = 0;
vr.isPulseTrial = false;
vr.pulseWasOn = false;
vr.dp4offset = 0;
vr.pulseTrialProbability = 0.3;
vr.driftPulseSd = 0.375;
vr.driftPulseMu = vr.driftPulseSd * 4;
vr.driftPulseHeightAbs = 0.06;
vr.driftPulseHeight = vr.driftPulseHeightAbs;
vr.minAccuracy = 0.5;
vr.accuracyEvalWindow = 30;


% Optogenetics parameters
vr.ops.optoAO_V = [5 5]; 
vr.optoOn = 0;
vr.Fs = 1e3;
vr.optoFreq = 40;
vr.optoDutyCycle = 50;
vr.optoDur = 60;
vr.optoMaxTrialTime_s = vr.optoDur - 2;
t = 0:1/vr.Fs:vr.optoDur - 1/vr.Fs;
optoSquareWave1 = (square(2*pi*vr.optoFreq*t, vr.optoDutyCycle)+1)'/2;
vr.optoSquareWave = repmat(optoSquareWave1, [1, 2]);
vr.ao.queueOutputData(vr.optoSquareWave.*vr.ops.optoAO_V);
disp('Successfully loaded stim data.')
vr.optoTrialProbability = 0.5; %0.5
vr.timeOut = 0;


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

if isTrialStart(vr)
    vr = updateLivePlots(vr);
    text(0, -7, ['Time outs: ' num2str(sum(vr.turnSide=="T"))])
    if vr.numRewards >= vr.maxNumRewards
        disp('Ended session because met max rewards.')
        vr.experimentEnded = true;
    end
    
    if (vr.numTrials > vr.accuracyEvalWindow+25)
        accuracy = mean(vr.correctTrials(end-vr.accuracyEvalWindow:end));
        if (accuracy < vr.minAccuracy)
            disp('Ending session because of low accuracy.')
            vr.experimentEnded = true;
        end
    end
   
    vr = initTrial(vr);
    vr.timeOut = 0;

     % Determine opto trial
    if rand < vr.optoTrialProbability
        vr.optoOn = 1;
        disp('Opto trial')
        vr.ao.startBackground;
        vr.optoTrialTime_s = 0;
        
    else
        vr.optoOn = 0;
    end
    
    % Determine heading pulse
    vr.inDriftPulse = 0;
    vr.dp4offset = 0;
    vr.pulseWasOn = false;
    if rand <= vr.pulseTrialProbability
        disp('Heading pulse trial')
        vr.isPulseTrial = true;
        % Randomly choose pulse going left or right
        pulseDirection = (randi([0 1]) -0.5)*2; % -1 or 1
        vr.driftPulseHeight = vr.driftPulseHeightAbs * pulseDirection;
    else
        vr.isPulseTrial = false;
    end
end

% Stop optogenetic stimulation
if vr.inITI && vr.optoOn
    vr.optoOn = 0;
    stop(vr.ao)
    vr.ao.outputSingleScan([0, 0]);
    vr.ao.queueOutputData(vr.optoSquareWave.*vr.ops.optoAO_V);
end

% Check for opto timeout
if vr.optoOn
    vr.optoTrialTime_s = vr.optoTrialTime_s + vr.dt;
    
    % End trial if photostim on for too long
    if (vr.inITI==0) && (vr.optoTrialTime_s > vr.optoMaxTrialTime_s)
        disp('Ended trial because exceeded max light time.')
        vr.timeOut = 1;
        vr.isCorrect = 0;
        vr.itiDur = vr.itiMiss;
        if mod(vr.currentWorld,2)==1
            % Note inverse from above because maze is flipped on screen
            vr.rewardedSide = [vr.rewardedSide "R"];
        else
            vr.rewardedSide = [vr.rewardedSide "L"];
        end
        vr.turnSide = [vr.turnSide "T"]; % T for timeout
        vr.behaviorData(9,vr.trialIterations) = 0; 
        vr = endTrialTMaze(vr);
    end
end

vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze(vr, vr.optoOn, vr.timeOut, vr.isPulseTrial, vr.inDriftPulse, vr.dp4offset);
if vr.isPulseTrial
    vr = headingDriftPulse(vr);
end    
% vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
vr = checkforTrialEndPosition_Tmaze(vr);

% Needs to be at the end to define vr.itiTime which triggers isTrialStart
vr = waitForNextTrial(vr);

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
stop(vr.ao)
vr.ao.outputSingleScan([0, 0]);

vr = clearAnalogChannels(vr);
savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats(vr);
