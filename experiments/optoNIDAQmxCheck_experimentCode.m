function code = optoNIDAQmxCheck_experimentCode
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
vr.optoOn = 0;
vr.optoLocation = 200;
vr.optoTimeOn = 0;
vr.optoDur = 1;
vr.optoITI = tic;
vr.optoITIDur = 0;
vr.optoNum = 0;

% single 30ms pulse
% vr.vIdx = 0;
% vr.vHigh = 3;
% vr.pulse_ms = 25;
% vr.post_ms = 5;
% vr.Rate = 1e3;
% vr.nHigh=round(vr.pulse_ms/1000*vr.Rate);
% vr.nPost=round(vr.post_ms/1000*vr.Rate);
% vr.yPulse = [vr.vHigh*ones(vr.nHigh,1); zeros(vr.nPost,1)];

% 7.5 Hz train for 4.5s
vr.vIdx = 0;
vr.vHigh = 4;
vr.pulse_ms = 30;
vr.post_ms = 103;
vr.Rate = 1e3;
vr.nHigh=round(vr.pulse_ms/1000*vr.Rate);
vr.nPost=round(vr.post_ms/1000*vr.Rate);
% vr.yPulse = [vr.vHigh*ones(vr.nHigh,1); zeros(vr.nPost,1)];
% vr.yPulse = repmat(vr.yPulse, 1, 33);

%vr.yPulse = makePulseTrain(vr.Rate, 7.5, 0.03, 4.5, vr.vHigh);
vr.yPulse = makePulseTrain(vr.Rate, 10, 10, 10, vr.vHigh);

vr = setupAO_PFI0(vr);


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
vr = collectBehaviorIter_TMaze(vr, vr.optoOn);
vr = checkForManualOptoNIDAQmx(vr); % Turn on opto stim if 'r' key pressed

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = clearAnalogChannels(vr);
releaseAO(vr);
resetNIDAQmx;
