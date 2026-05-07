function code = linearTrack_noReward_gainHalfBlocks10_5
% linearTrackNew   Code for the ViRMEn experiment linearTrackNew.
%   code = linearTrackNew   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT


%% MAZE DESCRIPTION
% Infinite linear maze (loops back on itself) with 4 wall cues and
% associated landmarks.

% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)

    % wrap world
    vr.mazeLength = eval(vr.exper.variables.mazewidth);
    vr = wrapLinearWorlds(vr);
    
    % Initialize VR
    vr.debugMode = false;
    vr.ops = getRigInfo();
    vr = makeVirmenDir(vr);
    vr = initLinearTrack(vr);
    vr = initDAQ(vr);
    vr = initLivePlots_linearMaze(vr);
    vr.gainRatio = 0.5;
    vr.initialGain = vr.ops.forwardGain;
    vr.highGainTrialTot = 10;
    vr.lowGainTrialTot = vr.highGainTrialTot * vr.gainRatio;
    vr.highGainTrialCount = 1;
    vr.lowGainTrialCount = 0;
    
    % Initialize maze
    vr.rewardLocation = 350;

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % Loop maze
    if vr.position(2) > vr.mazeLength
        vr = endLinearTrackTrial(vr);
        vr = initLinearTrackTrial(vr);
        vr.currentWorld = randsample(vr.worldsAvailable, 1, true, vr.worldProbability);
        vr = updateLivePlots_linearMaze(vr);
        
        if (vr.ops.forwardGain == vr.initialGain) && (vr.highGainTrialCount < vr.highGainTrialTot)
            vr.ops.forwardGain = vr.initialGain;
            vr.highGainTrialCount = vr.highGainTrialCount + 1;
        elseif (vr.ops.forwardGain == vr.initialGain) && (vr.highGainTrialCount == vr.highGainTrialTot)
            vr.ops.forwardGain = vr.initialGain * vr.gainRatio;
            vr.highGainTrialCount = 0;
            vr.lowGainTrialCount = 1;
        elseif (vr.ops.forwardGain == vr.initialGain * vr.gainRatio) && (vr.lowGainTrialCount < vr.lowGainTrialTot)
            vr.ops.forwardGain = vr.initialGain * vr.gainRatio;
            vr.lowGainTrialCount = vr.lowGainTrialCount + 1;
        else
            vr.ops.forwardGain = vr.initialGain;
            vr.highGainTrialCount = 1;
            vr.lowGainTrialCount = 0;
        end

        disp(['Trial ' num2str(vr.numTrials) ':'])
        disp(['-Gain: ' num2str(vr.ops.forwardGain)])
        disp(['-Count High Gain: ' num2str(vr.highGainTrialCount)])
        disp(['-Count Low Gain: ' num2str(vr.lowGainTrialCount)])
    
    end
    
    vr = outputVirmenTrigger(vr);
    
    vr = collectBehaviorIter_TMaze(vr, vr.ops.forwardGain);
    vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)

vr = updateLivePlots_linearMaze(vr);
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats_linearMaze(vr)
delete(instrfind);