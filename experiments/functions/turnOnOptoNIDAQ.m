function [vr] = turnOnOptoNIDAQ(vr, voltage, dur)
disp('Turn on LED');

firePulse(vr.ao, 5.0, 30);