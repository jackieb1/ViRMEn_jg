function code = linearTrack_none
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
yMazeLength = 400;
vr = wrapLinearWorlds(vr, yMazeLength);

vr.debugMode = false;
vr.ops = getRigInfo();
vr = makeVirmenDir(vr);
vr = initDAQ(vr);

vr.rewardDistance = 50;

vr.currentWorld = 2;




%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
if vr.numRewards >= vr.maxNumRewards
    vr.experimentEnded = true;
end

% Loop maze
if vr.position(2)>400
    vr.trialEnded = 1;
    vr.position(2) = vr.position(2)-400;
end



if abs(vr.currentRewardLocation-vr.position(2))>vr.reward.zoneRadius
    vr.localRewardsRemaining = 0;
end

% Uncomment for testing
% switch vr.keyPressed
%     case 49
%         % "1" key pressed: switch world to world 1
%         vr.currentWorld = 1;
%     case 50
%         vr.currentWorld = 2;
% end




% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
delete(instrfind);