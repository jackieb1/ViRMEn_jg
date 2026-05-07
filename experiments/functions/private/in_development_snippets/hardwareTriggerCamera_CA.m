vid = videoinput('gige', 1, 'Mono8');
src = getselectedsource(vid);

vid.FramesPerTrigger = 1;
vid.TriggerRepeat = Inf;
%src.AcquisitionFrameRateAbs = 60;
src.PacketSize = 9014;

triggerconfig(vid, 'hardware', 'DeviceSpecific', 'DeviceSpecific');

src.TriggerSelector = 'FrameStart';
src.TriggerSource = 'Line1';
src.TriggerActivation = 'RisingEdge';
src.TriggerMode = 'on';

% Specify a constant exposure time for each frame
src.ExposureMode = 'Timed';
src.ExposureTimeAbs = 10000;

% vid.TriggerRepeat = 1;
% 
vid.LoggingMode = 'disk';
path2store2 = 'C:\DATA\Charlotte\PupilDATA\test';
file2store = fullfile(path2store2, 'PupilData3.avi');
diskLogger = VideoWriter(file2store, 'Grayscale AVI');
% % 
vid.DiskLogger = diskLogger;

%preview(vid)

%%

%vr.vid.ROIPosition = [0 0 329 492];
%vid.ROIPosition = [0 246 329 246];

start(vid);
%wait(vid,10);

%%

[data2, ts2] = getdata(vid, vid.FramesAvailable);

%preview(vid) % previewing video while running virmen slows down virmen

figure;
imaqmontage(data2)