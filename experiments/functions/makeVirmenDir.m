function vr = makeVirmenDir(vr)

currentdir = cd;

if vr.debugMode
    vr.mouseNum = randi(1e6,1)+1e3;
    vr.basePath = 'C:\DATA\Debug';
else
    prompt = {'Mouse ID','Max Volume (ul)', 'Reward Size'};
    dlgtitle = 'Input Session Parameters';
    dims = [1 35];
    definput = {'', vr.ops.defaultMaxRewardVolume, vr.ops.defaultRewardSize};
    
    mouseInfo = inputdlg(prompt, dlgtitle, dims, definput);
    vr.mouseNum = mouseInfo{1};
    vr.maxRewardVolume = str2num(mouseInfo{2});
    vr.rewardSize = mouseInfo{3};
    vr.maxNumRewards = vr.maxRewardVolume / str2num(vr.rewardSize);
    vr.basePath = vr.ops.dataDirectory; 
end
formatOut = 'yymmdd';
vr.date = datestr(now,formatOut);
vr.fullPath = [vr.basePath filesep vr.mouseNum filesep vr.date];

%vr.fullPathCamera = strcat(vr.fullPath, '\PupilDATA'); %170819 commented

if ~exist(vr.fullPath,'dir')
   subFolder = 'session_1';
   vr.fullPath = [vr.fullPath filesep subFolder];
   mkdir(vr.fullPath);    
else
    warning('Path Already Exists!');
    % check for what subFolders exist in the directory already, then use a
    % session_ID that does not exist yet
    % list all Folders with name containing 'session'
    cd(vr.fullPath);
    
    sessionFolds = dir('session*');
    sessionFolds = sessionFolds([sessionFolds(:).isdir]); % only use items named session* that are folders
    session_ID = sessionFolds(numel(sessionFolds)).name; % get the latest session_ID folder
    session_ID = str2num(session_ID(end)); % get the number of the latest session folder
    subFolder = strcat('session_',num2str(session_ID+1)); % create a new subFolder with an incremented session_ID
    vr.fullPath = [vr.fullPath filesep subFolder];
    mkdir(vr.fullPath);
end
vr.sessionID = subFolder;

cd(currentdir)
 
end    