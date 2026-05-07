% run solenoid through

s = daq.createSession('ni')
s.addAnalogOutputChannel('Dev1','ao0', 'Voltage')
s.Rate = 1000;
ActualRate = s.Rate;

duration =10;

pulselength=ActualRate*duration;
pulsedata=5.0*ones(pulselength,1); %5V amplitude
pulsedata(pulselength)=0; %reset to 0V at last time point

pause(1) 

queueOutputData(s,pulsedata);
startForeground(s)
