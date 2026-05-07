function calibrateSolenoid_dan(n_pulses, delay, duration)
if nargin < 3
    duration = 0.08; % .012 -.029 duration = 0.035; %alice 130305
    % CA: 17-81^; 0.05 gives ca 4.3 ul reward
    % RBL: calibrateSolenoid_CA(300,.5,0.06) 4.3 ul reward 29-08-17
end
if nargin < 2
    delay = .25;
end
if nargin < 1
    n_pulses = 200;
end
daqreset;

s = daq.createSession('ni');
s.addAnalogOutputChannel('Dev1','ao0', 'Voltage')
s.Rate = 1000;
ActualRate = s.Rate;
% queueOutputData(s,[0 0 0 0 0]');
% startForeground(s)
% pulselength=ActualRate*duration;
% pulsedata=5.0*ones(pulselength,1); %5V amplitude
% pulsedata(end)=0; %reset to 0V at last time point

%set up number of pulses and pause between
for i=1:n_pulses
    disp(['i = ',num2str(i)]);
%     queueOutputData(s,pulsedata);
%     startForeground(s)
%     pause(delay);
outputSingleScan(s,[5]);
pause(duration)
outputSingleScan(s,[0]);
pause(delay)

end

end