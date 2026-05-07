function [vr] = triggerPhotoStimPC(vr, state)

% sends a ditigal signal to photostim PC:
% if state == 1 (high), photostim should be performed, if 0, no photostim

if state == 1
    outputSingleScan(vr.dio_photostim,1);
elseif state == 0
    outputSingleScan(vr.dio_photostim,0);

end