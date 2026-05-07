function code = gol_v02
% linearTrack_v3   Code for the ViRMEn experiment linearTrack_v3.
%   code = linearTrack_v3   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT



% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)
%% TODO:
% calibrate virmen unit to cm conversion

% set whether in debug mode:
vr.debugMode = 0;
vr.imaging = 1;
vr.drawText = 1;
daqreset;
%
ops = getRigSettings;

% initialize vr.session
vr.session = [];
vr.mouseID = makeMouseID_virmen(vr);
vr.session = struct(...
    ...% default entries
    'sessionID', [vr.mouseID '_' datestr(now,'YYmmDD_hhMMss')], ...
    'rig',ops.rigName,...
    'startTime',now(),...
    'experimentCode', mfilename,... % change this to get the actual maze name from vr
    ... % custom fields
    'trialMaxDuration', 45, ... % timeout countdown clock in seconds
    'targetRPM',8, ...
    'rewardSize',4, ...
    'airPuffLength', 0.2, ...
    'maxReward', eval(vr.exper.variables.maxReward), ... % maximum number of rewards before moving to post world
    'maxDuration', eval(vr.exper.variables.maxDuration), ... % maximum time in minutes before moving to post world
    'maxTrials', eval(vr.exper.variables.maxTrials), ... % maximum number of trials before moving to post world
    'rewardZoneRadius', 20 ...
    ); 

% names of variables (fields in vr) that will be saved on each iteration,
% followed by the number of elements in each of those.
% Each variable will be flattened and saved in a
% binary file in the order specified in saveVar.
vr.saveOnIter = {...
    'rawMovement',3;...
    'position',4;...
    'velocity',4;...
    'iN',1;...
    'tN',1;...
    'isITI',1;...
    'reward',1;...
    'isLick',1;...
    'isVisible',1;...
    'dt',1;...
    ... % custom fields
    'manualReward',1;...
    'manualAirpuff',1;...
    'punishment',1;...
    'isFrozen',1;... % whether the world is forzen
    'trialEnded',1;...
    'isBlackout',1;...
    'mazeEnded',1;...
    'analogSyncPulse',1;...
    'digitalSyncPulse',1 ...
};
    
% initialize vr.trialInfo
vr.trial(1:5000,1) = struct(...
    ...% the standard fields 
    'N',0,...
    'duration',0,...
    'totalReward',0,...
    'isCorrect',0,...
    'type',eval(vr.exper.variables.startingCondition),... % in this maze the trial type and the world are the same? This generates some redundancy and confusion
    'start',0,...
...%'world',vr.currentWorld,... % FOR NOW ASSUMING THAT WORLD IS "TYPE". I don't really see any major disadvantage to this at the moment (except that loading the world is time intensive)
    ...% general fields to all mazes:
    'startPosition', [0 0 eval(vr.exper.variables.mouseHeight) pi/2],... % position vector [X Y Z theta] defining where the mouse started the trial
... %%'endPosition', [],... % position vector [X Y Z theta] defining where the mouse ended the trial
    'blackoutDuration',0,... % "blackout" ITI at the beginning of trial
    'isProbe', 0, ...
    'isTimeout', 0 ...  % whether the trial timed out   
    );

%% define the reward and punishment locations (conditions) for each maze
vr.session.trialTypeNames = {'lineara','linearb','world1a','world1b','world2a','world2b'};

n = 1;
vr.condition(n).rewardLocations = [20 65 125 188 212 318];
vr.condition(n).rewardsPerLocation = [1 1 1 1 1 1];
vr.condition(n).rewardProb = [1 1 1 1 1 1]; 
vr.condition(n).world = 1;

n = 2;
vr.condition(n).rewardLocations = [5 188 451];
vr.condition(n).rewardsPerLocation = [2 2 2];
vr.condition(n).rewardProb = [1 1 1]; 
vr.condition(n).world = 1;

n = 3;
vr.condition(n).rewardLocations = [100];
vr.condition(n).rewardsPerLocation = [3];
vr.condition(n).rewardProb = [1]; 
vr.condition(n).world = 2;

n = 4;
vr.condition(n).rewardLocations = [300];
vr.condition(n).rewardsPerLocation = [3];
vr.condition(n).rewardProb = [1]; 
vr.condition(n).world = 2;

n = 5;
vr.condition(n).rewardLocations = [300];
vr.condition(n).rewardsPerLocation = [3];
vr.condition(n).rewardProb = [1]; 
vr.condition(n).world = 3;

n = 6;
vr.condition(n).rewardLocations = [100];
vr.condition(n).rewardsPerLocation = [3];
vr.condition(n).rewardProb = [1]; 
vr.condition(n).world = 3;

n = 7;
vr.condition(n).rewardLocations = [];
vr.condition(n).rewardsPerLocation = [];
vr.condition(n).rewardProb = []; 
vr.condition(n).world = 4;




vr.rewardLocationsRemaining = [];
vr.localRewardsRemaining = [];
vr.currentRewardLocation = [];

%
vr.binN = 1;
vr.binsEvaluated = 1;
vr.position = [0 0 eval(vr.exper.variables.mouseHeight) pi/2];

%%

%% common init
vr = commonInit(vr);

% wrap world 
for k = 1:length(vr.worlds)
nvert = size(vr.worlds{k}.surface.vertices,2);
xyzoffset = [0 400 0; 0 -400 0; 0 800 0]';
orig = vr.worlds{k};
for j = 1:size(xyzoffset,2)
offsetmat = repmat(xyzoffset(:,j),1,nvert);
vr.worlds{k}.surface.vertices =  [vr.worlds{k}.surface.vertices orig.surface.vertices+offsetmat];
vr.worlds{k}.surface.triangulation = [vr.worlds{k}.surface.triangulation orig.surface.triangulation+(nvert*j)];
vr.worlds{k}.surface.visible = [vr.worlds{k}.surface.visible orig.surface.visible];
vr.worlds{k}.surface.colors = [vr.worlds{k}.surface.colors orig.surface.colors];
end
end
vr.currentWorld = vr.condition(vr.trial(vr.tN).type).world;


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

vr = commonRuntime(vr,'iterStart');

if vr.position(2)>400
    vr.trialEnded = 1;
    vr.position(2) = vr.position(2)-400;
end

if abs(vr.currentRewardLocation-vr.position(2))>vr.session.rewardZoneRadius
    vr.localRewardsRemaining = 0;
end

% evaluate whether to give reward
if vr.isLick && ~isempty(vr.condition(vr.trial(vr.tN).type).rewardLocations) && ~vr.trial(vr.tN).isProbe
    if vr.localRewardsRemaining>0
        vr = giveReward(vr,vr.session.rewardSize);
        vr.localRewardsRemaining = vr.localRewardsRemaining - 1;
        
    elseif min(abs(vr.rewardLocationsRemaining-vr.position(2)))<=vr.session.rewardZoneRadius
        % find reward location
        [~,i] = min(abs(vr.rewardLocationsRemaining-vr.position(2)));
        vr.currentRewardLocation = vr.rewardLocationsRemaining(i);
        vr.rewardLocationsRemaining(i) = [];
        ind=find(vr.condition(vr.trial(vr.tN).type).rewardLocations==vr.currentRewardLocation);
        vr.localRewardsRemaining = vr.condition(vr.trial(vr.tN).type).rewardsPerLocation(ind);
        
        vr = giveReward(vr,vr.session.rewardSize);
        vr.localRewardsRemaining = vr.localRewardsRemaining - 1;
    else
        % do nothing.
    end    
end

% check to see if we enter the postWorld
if sum([vr.trial(1:vr.tN).totalReward])>vr.session.maxReward || ((now-vr.session.startTime)*24*60)>vr.session.maxDuration || vr.tN>vr.session.maxTrials
    [vr.trial(vr.tN+1:end).type] = deal(7);
end

% if mouse passes end of the maze, reset the trial & rewards 
if vr.trialEnded
    vr = commonRuntime(vr,'trialEnd');
    if mod(vr.tN,10)==0
        vr.trial(vr.tN).isProbe = 1;
    end
    % set the current type     
    vr.currentWorld = vr.condition(vr.trial(vr.tN).type).world;
    vr.rewardLocationsRemaining = vr.condition(vr.trial(vr.tN).type).rewardLocations;
end

vr = commonRuntime(vr,'iterEnd');





% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = commonTermination(vr);