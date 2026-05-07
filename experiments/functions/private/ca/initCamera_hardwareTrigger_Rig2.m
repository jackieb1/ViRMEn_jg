function vr = initCamera_hardwareTrigger_Rig2(vr)

% reset the previous imaq object, if existent
imaqreset;

% create a camera connection, specify acquisiton parameters
vr.vid = videoinput('gige', 1, 'Mono8');
vr.src = getselectedsource(vr.vid);

vr.vid.FramesPerTrigger = 1;
vr.vid.TriggerRepeat = Inf;
vr.src.PacketSize = 9014;

% specify trigger parameters
triggerconfig(vr.vid, 'hardware', 'DeviceSpecific', 'DeviceSpecific');

vr.src.TriggerSelector = 'FrameStart';
vr.src.TriggerSource = 'Line1';
vr.src.TriggerActivation = 'RisingEdge';
vr.src.TriggerMode = 'on';

% specify a constant exposure time for each frame
vr.src.ExposureMode = 'Timed';
vr.src.ExposureTimeAbs = 12000;

% specify logging info
vr.vid.LoggingMode = 'disk';
file2store = fullfile(vr.fullPathCamera, 'PupilData.avi');
diskLogger = VideoWriter(file2store, 'Grayscale AVI');

vr.vid.DiskLogger = diskLogger;

%vr.vid.ROIPosition = [0 246 329 246];
vr.vid.ROIPosition = [60 32 329 246];

start(vr.vid);
%preview(vr.vid) % previewing video while running virmen slows down virmen

end