function code = T_maze_optoFullTrialPreRampWorlds34_OneThirdTrials12
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

% Experiment-specific parameters
vr.optoRamp_s = 0.5;
vr.optoMaxTrialTime_s = 30; % 30
vr.optoMaxSessionTime_s = 1000; %1000
vr.optoSessionTime_s = 0;
vr.optoTrialTime_s = 0;
vr.optoOn = 0;
vr.optoOut = 0;
vr.timeOut = 0;
vr.ao0.outputSingleScan(0);
vr.ao1.outputSingleScan(0);
vr.currentWorld = randsample([1 2], 1); % First trial is always control
vr.worldProbability = [1/6 1/6 2/6 2/6]; % for testing


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

if isTrialStart(vr)
    vr = updateLivePlots(vr);
    text(0, -7, ['Time outs: ' num2str(sum(vr.turnSide=="T"))])
    if vr.numRewards >= vr.maxNumRewards
        disp('Ended session because met max rewards.')
        vr.experimentEnded = true;
    end
    
    if vr.optoSessionTime_s > vr.optoMaxSessionTime_s
        disp('Ended session because exceeded max light time.')
        vr.experimentEnded = true;
    end
    vr = initTrial(vr);
    vr.timeOut = 0;
end

% Determine optogenetic stimulation
if vr.inITI
    % Ramp up before start of trial
    if (vr.itiTime > (vr.itiDur - vr.optoRamp_s)) && (vr.nextWorld >= 3)
        if vr.optoOn
            vr.optoOut = 1 / vr.optoRamp_s * vr.optoTrialTime_s;
            vr.optoOut = min(vr.optoOut, 1); % max out at 1 for safety
        else
            % Turn photostim on
            disp('Opto trial.')
            vr.optoOut = 0;
            vr.optoOn = 1;
            vr.optoTrialTime_s = 0;
        end
    else
        vr.optoOn = 0;
        vr.optoOut = 0;
    end
else
    if vr.currentWorld >= 3
        vr.optoOn = 1;
        vr.optoOut = 1;
    else
        vr.optoOn = 0;
        vr.optoOut = 0;
    end
end

% Output optogenetic stimulation
if vr.optoOn
    vr.ao0.outputSingleScan(vr.optoOut*(vr.ops.optoAO0_V-vr.ops.optoOffset_V)+vr.ops.optoOffset_V);
    vr.ao1.outputSingleScan(vr.optoOut*(vr.ops.optoAO1_V-vr.ops.optoOffset_V)+vr.ops.optoOffset_V);
else
    vr.ao0.outputSingleScan(0);
    vr.ao1.outputSingleScan(0);
end

vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze(vr, vr.optoOn, vr.optoOut, vr.timeOut);
% vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
vr = checkforTrialEndPosition_Tmaze(vr);

% Check for opto timeout
if vr.optoOn
    % Integrate time with light on
    vr.optoSessionTime_s = vr.optoSessionTime_s + vr.dt;
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

% Needs to be at the end to define vr.itiTime which triggers isTrialStart
vr = waitForNextTrial(vr);



% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr.ao0.outputSingleScan(0);
vr.ao1.outputSingleScan(0);

vr = clearAnalogChannels(vr);
savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats(vr);
