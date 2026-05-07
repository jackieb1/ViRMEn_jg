function code = T_maze_blockEndZone
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

vr.fractionBlockEndZone = 0.35;
vr.endZoneBlocked = 0;

vr = initDAQ(vr);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze(vr, vr.endZoneBlocked);
%vr = adjustFriction_dan(vr);
vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
vr = checkforTrialEndPosition_Tmaze(vr);
vr = waitForNextTrial(vr);

if vr.endZoneBlocked == 1
    % Block reward zone on right side
    if vr.position(1) <= vr.xRewardZoneThresh * -0.9
        vr.position(1) = vr.xRewardZoneThresh * -0.9;
    end
end

if vr.endZoneBlocked == -1
    % Block reward zone on left side
    if vr.position(1) >= vr.xRewardZoneThresh * 0.9
        vr.position(1) = vr.xRewardZoneThresh * 0.9;
    end
end

if isTrialStart(vr)
    vr = initTrial(vr);
    if rand <= vr.fractionBlockEndZone
        if rand <= 0.5
            vr.endZoneBlocked = -1;
            disp('Trial end blocked on left side.')
        else
            vr.endZoneBlocked = 1;
            disp('Trial end blocked on right side.')
        end
    else
        vr.endZoneBlocked = 0;
        disp('Trial end available on both sides.')
    end
end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = clearAnalogChannels(vr);
[vr,sessionData] = collectTrialData(vr);
%vr = makeTMazeFigs(vr,sessionData);
