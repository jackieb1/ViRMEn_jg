function [vr] = turnOnLED(vr)
disp('Turn on LED');

msgToSend = 4;
vr.teensy.writeString(msgToSend);