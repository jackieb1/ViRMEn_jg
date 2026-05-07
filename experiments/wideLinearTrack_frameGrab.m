function code = wideLinearTrack_frameGrab
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
    dlgtitle = 'Input Playback Session';
    dims = [1 35];
    prompt = {'Mouse ID','Date (YYMMDD)', 'Session', 'Trial start', 'Trial end', 'Directory'};
    definput = {'', '', 'session_1', '1', '1', 'Z:\HarveyLab\Tier1\Jonathan\Behavior_Imaging_Data\Virmen'};
    dlgInfo = inputdlg(prompt, dlgtitle, dims, definput);
    vr.playbackMouseNum = dlgInfo{1};
    vr.playbackDate = dlgInfo{2};
    vr.playbackSession = dlgInfo{3};
    vr.parentDir = dlgInfo{6};
    vr.fullPath = fullfile(vr.parentDir, vr.playbackMouseNum, vr.playbackDate, vr.playbackSession); %insert path here
    temp = load(fullfile(vr.fullPath, 'sessionData.mat'), 'sessionData');
%     dt = mean(temp.sessionData(10, :));
%     t = cumsum(temp.sessionData(10, :));
    trial = temp.sessionData(12, :);
%     disp(['Mean dt:' num2str(dt)]);
%     vr.start_s = str2double(dlgInfo(4));
%     vr.end_s = str2double(dlgInfo(5));
%     vr.start_idx = find(t>vr.start_s, 1, 'first');
%     vr.end_idx = find(t>vr.end_s, 1, 'first');

    vr.trial_start = str2double(dlgInfo(4));
    vr.trial_end = str2double(dlgInfo(5));
    vr.start_idx = find(trial>=vr.trial_start, 1, 'first');
    vr.end_idx = find(trial>vr.trial_end, 1, 'first');
    vr.behavData = temp.sessionData(:, vr.start_idx:vr.end_idx);

    % vr.fullPath = fullfile(parentDir, 'JG655\240513\session_1'); %insert path here
    % vr.trialFile = 'Trial#099.mat';
%     temp = load(fullfile(vr.fullPath, 'sessionData.mat'),'behavData');
%     vr.behavData = temp.sessionData;
    mkdir(fullfile(vr.fullPath,'frameGrabs'));
    vr.currentWorld = vr.behavData(1,end);
    vr.iterNumber = 1;
    % vr.mazeLength = eval(vr.exper.variables.floorLength);
    % vr.floorLength = eval(vr.exper.variables.floorLength);
    % vr.cueLength = eval(vr.exper.variables.cueLength);
    % vr.bufferWidth = eval(vr.exper.variables.bufferWidth);
    % vr.floorWidth = eval(vr.exper.variables.floorWidth);
    vr.nWorlds = length(vr.worlds);
    % vr.inITI = 0;
    vr.frames = [];%zeros(200,200,size(vr.behavData,2));
    disp('Successfully loaded virmen data');


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    temp =  virmenGetFrame(2);
    vr.frames(:,:,vr.iterNumber) = squeeze(temp(:,:,1));
    if vr.behavData(8,vr.iterNumber)==0
        vr.worlds{vr.currentWorld}.surface.visible(:) = 1;
    else
        vr.worlds{vr.currentWorld}.surface.visible(:) = 0;
    end
    if vr.iterNumber<size(vr.behavData,2)
        vr.iterNumber = vr.iterNumber+1;
    else
        vr.experimentEnded=1;
    end


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
    frameData = vr.frames;
    save(fullfile(vr.fullPath, 'frameGrabs', ['trial_' num2str(vr.trial_start) '-' num2str(vr.trial_end) '.mat']), 'frameData', '-v7.3');
    disp('Successfully saved frames.')
    % vr = clearAnalogChannels(vr);
    % [vr,sessionData] = collectTrialData_dan(vr);
    %vr = makeTMazeFigs(vr,sessionData);
