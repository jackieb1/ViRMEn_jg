function [vr] = giveReward_Teensy(vr,amount,varargin)

%if vr.useSerial
%   %test for using serial communication on teensy
%     tic
	msgToSend = 3;
	vr.teensy.writeString(msgToSend);
% 	fprintf('Sent message: %s\n', msgToSend)
%     toc
end