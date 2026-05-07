function vr = initDAQ_dan_dev2(vr)
% Start the DAQ acquisition
if ~vr.debugMode
    daqreset; %reset DAQ in case it's still in use by a previous Matlab program
    vr.ai = daq.createSession('ni');
    h1 = vr.ai.addAnalogInputChannel('dev2','ai0','Voltage');
    h1.TerminalConfig = 'SingleEnded';
    h2 = vr.ai.addAnalogInputChannel('dev2','ai1','Voltage');
    h2.TerminalConfig = 'SingleEnded';
    h3 = vr.ai.addAnalogInputChannel('dev2','ai2','Voltage');
    h3.TerminalConfig = 'SingleEnded';
    h4 = vr.ai.addAnalogInputChannel('dev2','ai3','Voltage'); % this is lick sensor
    h4.TerminalConfig = 'SingleEnded';
    
    vr.ai.Rate = 1e3;
    vr.ai.NotifyWhenDataAvailableExceeds=50;
    vr.ai.IsContinuous=1;
    vr.aiListener = vr.ai.addlistener('DataAvailable', @avgMvData);
    startBackground(vr.ai),
    pause(1e-2),
    
    vr.ao = daq.createSession('ni');
    vr.ao.addAnalogOutputChannel('dev2','ao0','Voltage');
    vr.ao.Rate = 1e3;
    
    vr.dio = daq.createSession('ni');
    vr.dio.addDigitalChannel('dev2','Port0/Line0','OutputOnly');
    vr.optoDIO = daq.createSession('ni');
    vr.optoDIO.addDigitalChannel('dev2','Port0/Line7','OutputOnly');

end

end

function avgMvData(src,event)
    global daqData
    daqData = mean(event.Data,1);
end