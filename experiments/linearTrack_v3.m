function code = linearTrack_v3
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
vr.imaging = 0;
vr.drawText = 1;
vr.save = 1;
%
vr.nTextFields = 16;

% initialize vr.session
% vr.session contains all variables that do not vary trial-by-trial. One
% copy of this is saved
% each session.
vr.session = struct(...
    'experimenterRigID', 'lynn_behaviorRig2',...
    'mazeName','tAlternating_v2_phase00',... % change this to get the actual maze name from vr
    'mouseNum', vr.exper.variables.mouseNumber, ...
    ... % reward parameters
    'minRewardFraction', 0.5, ...
    'rewardSizeML', 0.0034, ...
    ... % trial duration parameters
    'trialMaxDuration', 45, ... % timeout countdown clock
    ... % RPM parameters
    'targetRPM',4, ...
    'minRPM',0, ... % minimum number of rewards given, regardless of performance - this
    ... % gain parameters
    'forwardGain', -150, ...
    'viewAngleGain', -1.0, ...
    ... % DO NOT CHANGE
    'tic', tic,...
    'startTime', now(), ...
    'stopTime', [], ...
    'nTrials', 0, ...
    'nCorrect', 0, ...
    'pCorrect', 0, ...
    'nRewards', 0, ...
    'criterionReached', 0 ...
    ); 

% initialize vr.trialInfo
% vr.trial contains all information about individual trials
% trial info is saved in every ITI of the subsequent trial. therefore only
% complete trials are included.

vr.trial = struct(...
    ...% the standard fields 
    'N',1,...
    'duration',0,...
    'totalReward',0,...
    'isCorrect',0,...
    'type',1,...
    'start',now(),...
    ...% custom fields
    'correctTarget', [0 0],... % XY coordinate defining the center of the reward zone
    'correctRadius', 15,... % distance that the mouse needs to be from the reward location to get the reward
    'incorrectTarget',[0 0],... % XY coordinate defining the center of the incorrect/punishment zone
    'incorrectRadius',15,... % distance that the mouse needs to be from incorrect loication for the trial to be counted as incorrect
    'startPosition', [0 -eval(vr.exper.variables.stemLength)+10 eval(vr.exper.variables.mouseHeight) pi/2],... % position vector [X Y Z theta] defining where the mouse started the trial
    'endPosition', [],... % position vector [X Y Z theta] defining where the mouse ended the trial
    ...
    ...
    ...
    'targetDir', [], ... % target direction = sign of target position X value.
    'turnDir',[],... % turn direction = sign of end position X value.
    'duration', [],... % duration of the trial in seconds
    'blackoutDuration',0.1,...
    'frozenDuration',2,...
    'trialStartTimeAbs', toc(vr.session.tic),... % time the trial started, relative to session start time
    'trialStopTimeAbs', [],... % time trial ended, relative to session start time
    'rewardN', 0,... % total number of rewards given on that trial
    'isCorrect', [], ... % whether the mouse got the trial correct
    'isTimeout', [], ...
    'leftTowerVisible',1,...
    'rightTowerVisible',1, ...
    'rewardTowerDeg',[],...
    'rewardFraction',[],...
    'twoTowerTrial',0, ...
    'leftTarget',[], ...
    'leftChoice',[]...
    );

% initialize vr.iter
% vr.iter contains  information about all  indidivual iteration of virmen.
% the amount of information stored in this should be kept to a minimum.
% the iteration data for the last trial is all saved during the ITI
% #note: this is different from what was done before, where iteration data
% was saved on every iteration. I think this system might be better?
% vr.iter is only kept for the last two trials

vr.iterCustom = struct(...
    'tic',[],...
    'trialN',[],... % current trial number
    'iterN',[],... % iterationNumber
    'iterInTrial',[],... % iteration in the trial
    'position',[],... % current position
    'velocity',[],... % current velocity
    'rewardN',[],... % number of rewards given on current iteration
    'lickN',[],... % count of licks
    'isITI',[],... % whether the mouse is in the ITI
    'isBlackout',[],... % whether the world is not visible
    'isFrozen',[],... % whether the world is forzen
    'isBrake',[],... % whether the ball is braked
    'startTimeAbs',[],... % absolute time
    'startTimeInTrial',[],... % time in trial (from trial start)
    'startTimeInSession',[], ... % time in session (from session start)
    'pitchRollYaw',[]...
    );

% set up the path
vr = initPath(vr,vr.session.experimenterRigID);

% set up the daq
vr = initDAQ(vr);

% initialize text boxes
cmap = lines(vr.nTextFields);
for k = 1:vr.nTextFields
    vr.text(k).string = '';
    vr.text(k).position = [1.1 .8-(0.1*(k-1))];
    vr.text(k).size = .03;
    vr.text(k).color = cmap(k,:);
end

%% initialize first trial
vr.iN = 0; % iteration total count
vr.iNT = 0; % interation in trial
vr.tN = 1; % trial number
vr.isITI = 0;
vr.mazeEnded = 0;

% randomize first turn direction
vr.trial(vr.tN).targetDir = sign(rand(1)-0.5); % this is just for getting the tower color
vr.trial(vr.tN).startingPosition = [0 -vr.trial(vr.tN).stemLength+10 eval(vr.exper.variables.mouseHeight) pi/2];

% set arm length & stem length
vr.exper.variables.stemLength = num2str(vr.trial(vr.tN).stemLength);
vr.exper.variables.armLength = num2str(vr.trial(vr.tN).armLength);

% set which tower is visible and set the tower location
switch vr.trial(vr.tN).targetDir
    case -1 % = right turn!!!! - remember x coordinates are flipped
        % make the right target the correct target and left the incorrect
        vr.trial(vr.tN).rightTowerVisible = 1;
        vr.trial(vr.tN).leftTowerVisible  = 0;
    case 1 % = left turn!!!!
        vr.trial(vr.tN).rightTowerVisible = 0;
        vr.trial(vr.tN).leftTowerVisible  = 1;
end

vr.trial(vr.tN).correctTarget = [vr.trial(vr.tN).targetDir*eval(vr.exper.variables.armLength), 20];
vr.trial(vr.tN).incorrectTarget = [-1*vr.trial(vr.tN).targetDir*eval(vr.exper.variables.armLength), 20];

if vr.trial(vr.tN).twoTowerTrial
    vr.trial(vr.tN).rightTowerVisible = 1;
    vr.trial(vr.tN).leftTowerVisible  = 1;
end

% set the radius
vr.exper.variables.rightTowerRadius = num2str(10*vr.trial(vr.tN).rightTowerVisible);
vr.exper.variables.leftTowerRadius = num2str(10*vr.trial(vr.tN).leftTowerVisible);
vr.trial(vr.tN).correctRadius = 15;
vr.trial(vr.tN).incorrectRadius = 15;
vr.trial(vr.tN).itiDuration = 2;

% reload world to update arm length and tower visibility
vr.worlds{1} = loadVirmenWorld(vr.exper.worlds{1});

% set reward positions
vr.position = vr.trial(vr.tN).startPosition;

vr.exper.variables.stemLength = num2str(vr.trial(vr.tN).stemLength);

%% define helper functions
vr.fun.euclideanDist = @(XY1,XY2)(sqrt(sum((XY1-XY2).^2)));

% make the textboxes
if vr.drawText
    vr.text(1).string = upper(['TIME: ' datestr(now-vr.session.startTime,'HH.MM.SS')]);
    vr.text(2).string = upper(['TRIALS: ' num2str(vr.session.nTrials)]);
    vr.text(3).string = upper(['REWARDS: ' num2str(0)]);
    vr.text(4).string = upper(['PRCT: ' num2str(vr.session.pCorrect)]);
end

%% Save copy of the virmen directory exactly as it is when this code is run
virmenArchivePath = [vr.session.savePathFinal filesep vr.session.experimenter sprintf('%03d',eval(vr.exper.variables.mouseNumber)) '_virmenArchive' filesep vr.session.baseFilename '_virmenArchive'];
if ~exist(virmenArchivePath,'dir')
    mkdir(virmenArchivePath);
end
copyfile('C:\Users\harveyadmin\Desktop\virmen',virmenArchivePath);
disp('virmen code archived');

if vr.save
    save([vr.session.savePathFinal, filesep, vr.session.baseFilename '_vr.mat'], 'vr', '-v7.3');
end
disp('vr structure saved');

vr.arduino = [];
vr = giveRewardPump(vr,1);
vr = rewardTone(vr,1);

vr.isBlackout = 0;
vr.isFrozen = 0;
vr.trialEnded = 0;
vr.mazeEnded = 0;




% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)



% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
