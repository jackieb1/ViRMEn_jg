function vr = initCamera_Rig2(vr)

% reset the previous imaq object, if existent
imaqreset;

% create a camera connection, specify acquisiton parameters

vr.vid = videoinput('gige', 1, 'Mono8');
vr.src = getselectedsource(vr.vid);

vr.vid.FramesPerTrigger = 1;
vr.src.AcquisitionFrameRateAbs = 60;
vr.src.PacketSize = 9014;

% calculate and set package delay automatically to avoid dropping frames
delay = CalculatePacketDelay(vr.vid, 60); 
vr.src.PacketDelay = delay;

%vr.src.TriggerSource = 'Software';
vr.src.FrameStartTriggerSource = 'Software';


triggerconfig(vr.vid, 'manual');
vr.vid.TriggerRepeat = Inf;

vr.vid.LoggingMode = 'disk';
file2store = fullfile(vr.fullPathCamera, 'PupilData.avi');
diskLogger = VideoWriter(file2store, 'Grayscale AVI');

vr.vid.DiskLogger = diskLogger;

% vr.vid.ROIPosition = [0 0 329 492];
 vr.vid.ROIPosition = [0 246 329 246];
 
%vr.vid.ROIPosition = [156  112  329  246];

start(vr.vid);

preview(vr.vid) % previewing video while running virmen slows down virmen

end