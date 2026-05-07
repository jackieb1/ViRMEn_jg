function vr = makeDirSNC_CA(vr)

if vr.debugMode
    vr.mouseNum = randi(1e6,1)+1e3;
    vr.basePath = 'C:\DATA\Debug';
else    
    mouseInfo = inputdlg('Input the Mouse Number: ');
    vr.mouseNum = str2double(mouseInfo{1});
    vr.basePath = 'C:\DATA\Charlotte'; % directory for VR behavior data
    vr.basePathCamera = 'C:\DATA\Charlotte\PupilDATA'; % directory for pupil data
end
vr.date = date;
vr.fullPath = [vr.basePath filesep num2str(vr.mouseNum) filesep vr.date];
vr.fullPathCamera = [vr.basePathCamera filesep num2str(vr.mouseNum) filesep vr.date];

if ~exist(vr.fullPath,'dir')
    mkdir(vr.fullPath);
else
    warning('Path Already Exists!');
    subFolder = input('Input specification: ','s');
    vr.fullPath = [vr.fullPath filesep subFolder];
    mkdir(vr.fullPath);
end

if ~exist(vr.fullPathCamera,'dir')
    mkdir(vr.fullPathCamera);
else
    warning('Path Already Exists!');
    subFolder = input('Input specification: ','s');
    vr.fullPathCamera = [vr.fullPathCamera filesep subFolder];
    mkdir(vr.fullPathCamera);
end
    
end    