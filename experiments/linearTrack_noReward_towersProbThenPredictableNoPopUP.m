function code = linearTrack_noReward_towersProbThenPredictableNoPopUP

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
    vr.baseWorlds = vr.worlds;
    vr = wrapLinearWorlds(vr);
    
    % Initialize VR
    vr.debugMode = false;
    vr.ops = getRigInfo();
    vr = makeVirmenDir(vr);
    vr = initLinearTrack(vr);
    vr = initDAQ(vr);
    vr = initLivePlots_linearMaze(vr);
    
    % Initialize maze
    vr.rewardLocation = 350;
    vr.switchTrial = 50;
    vr.tower_location = 50;
    vr.tower_appeared = 0;
    vr.towerProbability = 0.2;
    vr.towerCount = 0; 
    vr.switchTowerCount = 30;

    % Pre-draw tower sequence (1 = tower on that trial) so the wrapped copies
    % ahead show the actual upcoming trials. Trials 1-50 no tower, then 20%
    % until 30 towers, then always.
    vr.towerSeq = zeros(1,5000);
    for k = vr.switchTrial+1:numel(vr.towerSeq)
        if sum(vr.towerSeq(vr.switchTrial:k-2)) < vr.switchTowerCount
            vr.towerSeq(k) = rand < vr.towerProbability;
        else
            vr.towerSeq(k) = 1;
        end
    end
    vr = setTowerWorld(vr);

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % Loop maze
    if vr.position(2) > vr.mazeLength/2
        vr = endLinearTrackTrial(vr);
        vr = initLinearTrackTrial_doubleLength(vr);
        vr = setTowerWorld(vr);
        disp(['World: ' num2str(vr.currentWorld)]);
        disp(['Towers so far: ' num2str(vr.towerCount)]);
        vr = updateLivePlots_linearMaze(vr);
    end

    vr = outputVirmenTrigger(vr);
    vr = collectBehaviorIter_TMaze(vr);
    vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed

% Set world for current trial c (world = 1 + 2*tower(c) + tower(c+1)) and
% build the wrapped copies from the trials they stand in for.
function vr = setTowerWorld(vr)
    c = vr.numTrials + 1;
    s = vr.towerSeq;
    w = @(k) 1 + 2*s(max(k,1)) + s(max(k+1,1));
    vr.currentWorld = w(c);
    vr.towerCount = sum(s(1:c));
    vr = wrapLinearWorlds_lookahead(vr, [w(c) w(c+2) w(c-2) w(c+4)]);


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)

vr = updateLivePlots_linearMaze(vr);
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats_linearMaze(vr)
delete(instrfind);