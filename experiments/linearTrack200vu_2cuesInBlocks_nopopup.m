function code = linearTrack_2cuesInBlocks_nopopup
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
%     vr = wrapLinearWorld(vr, 1, 1);
%     vr = wrapLinearWorld(vr, 2, 1);
    
    % Initialize VR
    vr.debugMode = false;
    vr.ops = getRigInfo();
    vr = makeVirmenDir(vr);
    vr = initLinearTrack(vr);
    vr = initDAQ(vr);
    vr = initLivePlots_linearMaze(vr);
    
    % Initialize maze
    vr.cueBlockSize = 100;
    vr.currentBlockWorld = randi([2 3], 1);
    vr.currentWorld = vr.currentBlockWorld;
    

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % Loop maze
    if vr.position(2) > vr.mazeLength
        vr = endLinearTrackTrial(vr);
        vr = initLinearTrackTrial(vr);
        vr = updateLivePlots_linearMaze(vr);
        
        % Determine block ID at the beginning of each trial
        if mod(vr.numTrials, vr.cueBlockSize) == 0
            % If finish block, switch cue
            if vr.currentBlockWorld == 2
                vr.currentBlockWorld = 3;
            else
                vr.currentBlockWorld = 2;
            end
        end
        vr.currentWorld = vr.currentBlockWorld;
    end
    
    vr = outputVirmenTrigger(vr);

    vr = collectBehaviorIter_TMaze(vr, vr.currentBlockWorld);
    vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
    
    vr.behaviorData(9,vr.trialIterations) = 0;

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = clearAnalogChannels(vr);
savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats_linearMaze(vr)
delete(instrfind);