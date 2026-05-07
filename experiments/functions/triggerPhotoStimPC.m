function [vr] = triggerPhotoStimPC(vr, state)

% sends a ditigal signal to photostim PC:
% if state == 1: photostim 
% if state == 0: no photostim

outputSingleScan(vr.optoDIO, state);

end