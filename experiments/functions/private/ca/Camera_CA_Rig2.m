%% m-file to preview pupillometry camera for optimal positioning

vid = videoinput('gige', 1, 'Mono8');
src = getselectedsource(vid);

%vid.ROIPosition = [0 246 329 246]; % set the ROI position (needs to match parameters in initCamera file)
vid.FramesPerTrigger = 1;

src.AcquisitionFrameRateAbs = 60;
src.PacketSize = 9014;

vid.ROIPosition = [60 32 329 246];
%vid.ROIPosition = [308 108 329 246];

vr.src.ExposureTimeAbs = 12000;

delay = CalculatePacketDelay(vid, 60);

src.PacketDelay = delay;

preview(vid)

im = getsnapshot(vid);
%% 
imshow(im)

position = [];

rect = [0 246 329 246];
% select rectangle with predefined size
h = imrect(gca, rect);

addNewPositionCallback(h,@(p) title(mat2str(p,3)));
fcn = makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'));
setPositionConstraintFcn(h,fcn);
position = wait(h);

I2 = imcrop(im,position);
%imshow(I2);   % the output image of your ROI


%% 
stoppreview(vid)
clear vid src