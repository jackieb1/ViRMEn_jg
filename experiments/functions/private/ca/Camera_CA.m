%% m-file to preview pupillometry camera for optimal positioning

vid = videoinput('gige', 1, 'Mono8');
src = getselectedsource(vid);
vid.ROIPosition = [0 246 329 246]; % set the ROI position (needs to match parameters in initCamera file)
vid.FramesPerTrigger = 1;

src.AcquisitionFrameRateAbs = 60;
src.PacketSize=8000;

preview(vid)

%% 
stoppreview(vid)
clear vid src
