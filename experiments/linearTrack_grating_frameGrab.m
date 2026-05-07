function code = linearTrack_grating_frameGrab
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
parentDir = 'Z:\HarveyLab\Tier1\Jonathan\Behavior_Imaging_Data\Virmen';
%parentDir = 'D:\DATA\Jonathan';
%prompt = {'Mouse ID', 'Date', 'Session', 'Trial',};
%dlgtitle = 'Session Trial Input';
%dims = [1 35];
%definput = {'', vr.ops.defaultMaxRewardVolume, vr.ops.defaultRewardSize};
%sessionInfo = inputdlg(prompt, dlgtitle, dims);%, definput);

% Load session data
vr.fullPath = fullfile(parentDir, 'JG569\231216\session_1'); %insert path here
vr.trialNum = '099';
vr.trialFile = ['Trial#' vr.trialNum '.mat'];
temp = load(fullfile(vr.fullPath, vr.trialFile),'behavData');
vr.behavData = temp.behavData;
mkdir(fullfile(vr.fullPath,'frameGrabs'));
mkdir(fullfile(vr.fullPath, 'frameGrabs', [vr.trialNum '_frameGrabs']));

% wrap world
vr.mazeLength = eval(vr.exper.variables.mazewidth);
disp(vr.worlds)
vr = wrapLinearWorlds(vr);

vr.currentWorld = vr.behavData(1,1);
vr.iterNumber = 1;
vr.nWorlds = length(vr.worlds);
vr.frames = [];
disp('Successfully loaded virmen data');


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
vr.currentWorld = vr.behavData(1, vr.iterNumber);
temp =  virmenGetFrame(2);
vr.frames(:,:) = squeeze(temp(:,:,1));
vr.worlds{vr.behavData(1,vr.iterNumber)}.surface.visible(:) = 1;
if vr.iterNumber<size(vr.behavData,2)
    vr.iterNumber = vr.iterNumber+1;
else
    vr.experimentEnded=1;
end

frameData = vr.frames;
save(fullfile(vr.fullPath, 'frameGrabs', [vr.trialNum '_frameGrabs'], ['Trial' vr.trialNum '_' num2str(vr.iterNumber, '%04d')]), 'frameData', '-v7.3');
disp('Successfully saved frames.')



% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
%frameData = vr.frames;
%save(fullfile(vr.fullPath, 'frameGrabs', vr.trialFile), 'frameData', '-v7.3');
disp('Successfully saved frames.')
% vr = clearAnalogChannels(vr);
% [vr,sessionData] = collectTrialData_dan(vr);
%vr = makeTMazeFigs(vr,sessionData);
