function code = T_maze_cdh_opto
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
vr = makeVirmenDir_dan(vr);
vr = initTMaze_opto(vr);
vr = initDAQ_dan_dev2(vr);
vr.currentWorld = vr.trialList(1);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze_dan(vr);
vr = checkForOptoStimPosition(vr);
vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
vr = checkforTrialEndPosition_Tmaze_cdh(vr);
vr = waitForNextTrial_opto(vr);

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = clearAnalogChannels(vr);
[vr,sessionData] = collectTrialData_dan(vr);
%vr = makeTMazeFigs(vr,sessionData);
