function code = T_maze_cdh_frameGrab
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
vr.fullPath = 'Z:\HarveyLab\Tier1\Jonathan\Behavior_Imaging_Data\Virmen\JG741\241024\session_1'; %insert path here
temp = load(fullfile(vr.fullPath,'Trial#000.mat'),'behavData');
vr.behavData = temp.behavData;
mkdir(fullfile(vr.fullPath,'frameGrabs'));
vr.currentWorld = vr.behavData(1,1);
vr.iterNumber = 1;
vr.mazeLength = eval(vr.exper.variables.floorLength);
vr.floorLength = eval(vr.exper.variables.floorLength);
vr.cueLength = eval(vr.exper.variables.cueLength);
vr.bufferWidth = eval(vr.exper.variables.bufferWidth);
vr.floorWidth = eval(vr.exper.variables.floorWidth);
vr.nWorlds = length(vr.worlds);
vr.inITI = 0;
vr.frames = [];%zeros(200,200,size(vr.behavData,2));
disp('Successfully loaded virmen data');


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
temp =  virmenGetFrame(1); %virmenGetFrame(2)
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
save(fullfile(vr.fullPath,'frameGrabs','Trial#150.mat'),'frameData');
% vr = clearAnalogChannels(vr);
% [vr,sessionData] = collectTrialData_dan(vr);
%vr = makeTMazeFigs(vr,sessionData);
