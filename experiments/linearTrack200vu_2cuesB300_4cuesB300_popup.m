function code = linearTrack200vu_2cuesB300_4cuesB300_popup
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
    vr.twoCuesWorldProbability = [0 0.5 0.5];
    vr.fourCuesWorldProbability = [0 0.25 0.25 0.25 0.25];
    vr.twoCuesWorlds = [1 2 3];
    vr.fourCuesWorlds = [1 2 3 4 5];
    vr.cueHasAppeared = 0;
    vr.twoCuesBlockLength = 300;
    vr.fourCuesBlockLength = 300;
    vr.fourCuesBlock = 0;
    vr.numInBlock = 0;

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
        if vr.fourCuesBlock
            if vr.numInBlock < vr.fourCuesBlockLength
                vr.numInBlock = vr.numInBlock + 1;
                vr.currentWorld = randsample(vr.fourCuesWorlds, 1, true, vr.fourCuesWorldProbability);
            else
                vr.numInBlock = 1;
                vr.currentWorld = randsample(vr.twoCuesWorlds, 1, true, vr.twoCuesWorldProbability);
                vr.fourCuesBlock = 0;
            end
        else
            if vr.numInBlock < vr.twoCuesBlockLength
                vr.numInBlock = vr.numInBlock + 1;
                vr.currentWorld = randsample(vr.twoCuesWorlds, 1, true, vr.twoCuesWorldProbability);
            else
                vr.numInBlock = 1;
                vr.currentWorld = randsample(vr.fourCuesWorlds, 1, true, vr.fourCuesWorldProbability);
                vr.fourCuesBlock = 1;
            end 
        end
        disp([vr.currentWorld vr.fourCuesBlock vr.numInBlock])
        vr.cueHasAppeared = 1;
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

if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats_linearMaze(vr)
delete(instrfind);