function code = wideLinearTrack_playBack
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
% vr = initTMaze(vr);
vr = initDAQ(vr);
% vr = initLivePlots(vr);

% Load previous session
vr = loadSessionData(vr);

% Initialize maze
vr.iterNumber = 1;
vr.numColumns = size(vr.behavData, 1);
% vr.sessionData = zeros(vr.numColumns+1, 500000); % 1 hour session is 216000 time points at 60 Hz
vr.dts = zeros(500000, 1);
vr.printdtNumber = 1;
vr.lastTrialNumber = 0;
vr.currentWorld = vr.behavData(1, 1);
vr.nWorlds = length(vr.worlds);
disp('Successfully loaded virmen data');

% Print session length
playbackSessionTime = sum(vr.behavData(10, :));
fprintf('Playback session time: %0.2f min\n', playbackSessionTime/60);


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
% Send Virmen triggers
% vr = outputVirmenTrigger(vr);

% Set world (position is set in movement function)
vr.currentWorld = vr.behavData(1, vr.iterNumber);

vr.dts(vr.iterNumber) = vr.dt;

% Print dt
% iterationPeriod = 3600;
% if vr.iterNumber > vr.printdtNumber * iterationPeriod
%     mean_dt = mean(vr.dts(iterationPeriod*(vr.printdtNumber-1)+1:iterationPeriod*vr.printdtNumber));
% %     mean_dt = mean(vr.sessionData(vr.numColumns+1, iterationPeriod*(vr.printdtNumber-1)+1:iterationPeriod*vr.printdtNumber));
%    fprintf('mean dt: %0.4f\n', mean_dt)
%     vr.printdtNumber = vr.printdtNumber + 1;
% end

% End experiment when done playback
if vr.iterNumber<size(vr.behavData,2)
    vr.iterNumber = vr.iterNumber+1;
else
    vr.experimentEnded=1;
end


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
% Save playback session data
sessionDataName = fullfile(vr.fullPath, 'sessionData');
experData = vr.exper;

% sessionData = vr.sessionData(:, 1:vr.iterNumber);
sessionData = vr.behavData(:, 1:vr.iterNumber);
sessionData(vr.numColumns+1, :) = vr.dts(1:vr.iterNumber);
save(sessionDataName, 'sessionData', 'experData')

% Save playback session info to text file for easy access by python
textFileName = fullfile(vr.fullPath, 'playbackInfo.txt');
fid = fopen(textFileName, 'w');
fprintf(fid, [vr.playbackMouseNum ' ' vr.playbackDate ' ' vr.playbackSession]);
fclose(fid);