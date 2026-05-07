function code = linearTrack200vu_2cues_popup_playback
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
    
    % Load previous session
    vr = loadSessionData(vr);
    vr.numColumns = size(vr.behavData, 1);
    
    % Initialize maze
    vr.iterNumber = 1;
    vr.printdtNumber = 1;
    vr.CueRevealPosition = 80;
    vr.CueEndPosition = 120;
    vr.currentWorld = 1;
    vr.rewardProbability = 1;
    vr.worldProbability = [0.2 0.4 0.4];
    vr.cueHasAppeared = 0;
    
    % Print session length
    playbackSessionTime = sum(vr.behavData(10, :));
    fprintf('Playback session time: %0.2f min\n', playbackSessionTime/60);

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % Send Virmen triggers
    vr = outputVirmenTrigger(vr);

    % Set world (position is set in movement function)
    vr.currentWorld = vr.behavData(1, vr.iterNumber);
    %vr.dts(vr.iterNumber) = vr.dt;

    % Print dt
    iterationPeriod = 3600;
    if vr.iterNumber > vr.printdtNumber * iterationPeriod
        mean_dt = mean(vr.dts(iterationPeriod*(vr.printdtNumber-1)+1:iterationPeriod*vr.printdtNumber));
    %     mean_dt = mean(vr.sessionData(vr.numColumns+1, iterationPeriod*(vr.printdtNumber-1)+1:iterationPeriod*vr.printdtNumber));
       fprintf('mean dt: %0.4f\n', mean_dt)
        vr.printdtNumber = vr.printdtNumber + 1;
    end

    % End experiment when done playback
    if vr.iterNumber<size(vr.behavData,2)
        vr.iterNumber = vr.iterNumber+1;
        vr.dts(vr.iterNumber) = vr.dt;
    else
        vr.experimentEnded=1;
    end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)

% Save playback session data
sessionDataName = fullfile(vr.fullPath, 'sessionData');
experData = vr.exper;

disp(vr.iterNumber);
disp(size(vr.dts));

sessionData = vr.behavData(:, 1:vr.iterNumber);
sessionData(vr.numColumns+1, :) = vr.dts(1:vr.iterNumber);
save(sessionDataName, 'sessionData', 'experData')

% Save playback session info to text file for easy access by python
textFileName = fullfile(vr.fullPath, 'playbackInfo.txt');
fid = fopen(textFileName, 'w');
fprintf(fid, [vr.playbackMouseNum ' ' vr.playbackDate ' ' vr.playbackSession]);
fclose(fid);

vr = clearAnalogChannels(vr);
printSessionStats_linearMaze(vr)
delete(instrfind);