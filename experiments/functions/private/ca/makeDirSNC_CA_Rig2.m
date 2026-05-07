function vr = makeDirSNC_CA_Rig2(vr)

currentdir = cd;

if vr.debugMode
    vr.mouseNum = randi(1e6,1)+1e3;
    vr.basePath = 'C:\DATA\Debug';
else    
    mouseInfo = inputdlg('Input the Mouse Number: ');
    vr.mouseNum = str2double(mouseInfo{1});
    vr.basePath = 'C:\DATA\Charlotte'; % directory for VR behavior data
    %vr.basePathCamera = 'C:\DATA\Charlotte\PupilDATA'; % directory for pupil data
end
vr.date = date;
vr.fullPath = [vr.basePath filesep num2str(vr.mouseNum) filesep vr.date];

if ~exist(vr.fullPath,'dir')
   subFolder = 'session_1';
   vr.fullPath = [vr.fullPath filesep subFolder];
   %vr.fullPathCamera = [vr.fullPath filesep 'PupilDATA'];
   mkdir(vr.fullPath);
   %mkdir(vr.fullPathCamera); 
    
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
    %vr.fullPathCamera = strcat(vr.fullPath, '\PupilDATA');
    %mkdir(vr.fullPathCamera);
end

cd(currentdir)

end    