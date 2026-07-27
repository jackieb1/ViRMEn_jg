function code = linearTrack200vu_2cues_popup_100tBlocks
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
    vr.CueRevealPosition = 80;
    vr.CueEndPosition = 120;
    vr.currentWorld = 1;
    vr.rewardProbability = 1;
    vr.worldProbability = [0.2 0.4 0.4];
    vr.cueHasAppeared = 0;
    vr.blockSize = 100;
    vr.numInBlock = 0;
    vr.pastWorld = 2;

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % Loop maze
    if vr.position(2) > vr.mazeLength
        vr = endLinearTrackTrial(vr);
        vr = initLinearTrackTrial(vr);
        vr = updateLivePlots_linearMaze(vr);
        vr.currentWorld = 1;
        vr.cueHasAppeared = 0;
    end
    
    vr = outputVirmenTrigger(vr);
    
    if (~vr.cueHasAppeared) && (vr.position(2) > vr.CueRevealPosition)
        if vr.numInBlock < vr.blockSize
            vr.currentWorld = vr.pastWorld;
            vr.numInBlock = vr.numInBlock + 1;
        else
            if vr.pastWorld == 2
                vr.currentWorld = 3;
            else
                vr.currentWorld = 2;
            end
            vr.numInBlock = 1;
        end
        disp(vr.currentWorld)
        vr.cueHasAppeared = 1;
        vr.pastWorld = vr.currentWorld;
    end

    if vr.cueHasAppeared && (vr.position(2) > vr.CueEndPosition)
        vr.currentWorld = 1;
    end

        
    vr = collectBehaviorIter_TMaze(vr);
    vr.behaviorData(9,vr.trialIterations) = 0;
    vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed

    



% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = clearAnalogChannels(vr);
savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
vr = writePerformanceToExcel(vr);

if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats_linearMaze(vr)
delete(instrfind);