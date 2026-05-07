function [vr] = turnOffLED(vr)
disp('Turn off LED');

msgToSend = 5;
vr.teensy.writeString(msgToSend);