function code = rewardCheck_experimentCode
% Linear Track   Code for the ViRMEn experiment T_maze.
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
vr = initTMaze(vr);
vr = initDAQ(vr);
vr.worlds{vr.currentWorld}.backgroundColor = [0 0 0];
vr.worlds{vr.currentWorld}.surface.visible(:) = 0;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
vr = collectBehaviorIter_TMaze(vr);
if vr.isLick
    disp('lick detected')
end
vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = clearAnalogChannels(vr);
