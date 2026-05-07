function [vr] = triggerCamera(vr)

%trig_dur = 0.01; % duration of digital out high signal 

% can't use same syntax as for triggering analog out (e.g. solenoid) for
% digital out, as digital operations not clocked on the NIDAQ device

outputSingleScan(vr.dio, 1);
pause(0.0005);
outputSingleScan(vr.dio, 0);

% actualRate = vr.dio.Rate; %get sample rate
% pulselength=round(actualRate*trig_dur); %find duration (rate*duration in seconds *numRew)
% pulsedata=ones(pulselength,1); % binary signal
% pulsedata(pulselength)=0; %reset to 0 at last time point
% 
% vr.dio.queueOutputData(pulsedata);
% startForeground(vr.dio);

end