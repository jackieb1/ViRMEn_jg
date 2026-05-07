function ai = calibrateDAQ
daqreset; %reset DAQ in case it's still in use by a previous Matlab program
ai = daq.createSession('ni');
h1 = ai.addAnalogInputChannel('dev1','ai0','Voltage');
h1.TerminalConfig = 'SingleEnded';
h2 = ai.addAnalogInputChannel('dev1','ai1','Voltage');
h2.TerminalConfig = 'SingleEnded';
h3 = ai.addAnalogInputChannel('dev1','ai2','Voltage');
h3.TerminalConfig = 'SingleEnded';
ai.Rate = 1e3;
ai.NotifyWhenDataAvailableExceeds=1e3;
ai.IsContinuous=1;
aiListener = ai.addlistener('DataAvailable', @avgMvData);
startBackground(ai),

end

function avgMvData(src,event)
    mvData = mean(event.Data,1);
    fprintf('%04f, %04f, %04f \n',mvData(1),mvData(2),mvData(3))
end