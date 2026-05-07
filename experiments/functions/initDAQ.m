function vr = initDAQ(vr)
% Start the DAQ acquisition
if ~vr.debugMode
    daqreset; %reset DAQ in case it's still in use by a previous Matlab program
    vr.ai = daq.createSession("ni");
    h1 = vr.ai.addAnalogInputChannel(vr.ops.dev,'ai0','Voltage');
    h1.TerminalConfig = 'SingleEnded';
    h2 = vr.ai.addAnalogInputChannel(vr.ops.dev,'ai1','Voltage');
    h2.TerminalConfig = 'SingleEnded';
    h3 = vr.ai.addAnalogInputChannel(vr.ops.dev,'ai2','Voltage');
    h3.TerminalConfig = 'SingleEnded';
    h4 = vr.ai.addAnalogInputChannel(vr.ops.dev,'ai3','Voltage'); % this is lick sensor
    h4.TerminalConfig = 'SingleEnded';
    
    vr.ai.Rate = 1e3;
    vr.ai.NotifyWhenDataAvailableExceeds=50;
    vr.ai.IsContinuous=1;
    vr.aiListener = vr.ai.addlistener('DataAvailable', @avgMvData);
    startBackground(vr.ai),
    pause(1e-2),
    
%     vr.ao = daq.createSession('ni'); 10/29/25 (HK) - comment out to
%     initialize AO0 in DAQmx task
%     vr.ao.addAnalogOutputChannel(vr.ops.dev, 'ao0', 'Voltage');
% %     vr.ao.addAnalogOutputChannel(vr.ops.dev, 'ao1', 'Voltage');
%     vr.ao.Rate = 1e3;

    vr.dio = daq.createSession('ni');
    vr.dio.addDigitalChannel(vr.ops.dioDev, 'Port0/Line0', 'OutputOnly'); % Virmen trigger

    vr.optoDIO = daq.createSession('ni');
    vr.optoDIO.addDigitalChannel(vr.ops.dioDev, vr.ops.optoDIOPort, 'OutputOnly'); % photostim trigger
    
    % Saved from before as reference for troubleshooting
%     vr.dio = daq.createSession('ni');
%     vr.dio.addDigitalChannel(vr.ops.dev,'Port0/Line0','OutputOnly');
%     vr.optoDIO = daq.createSession('ni');
%     vr.optoDIO.addDigitalChannel(vr.ops.dev,'Port0/Line7','OutputOnly');

    
    if vr.ops.useTeensyReward
        vr = initTeensy(vr);
    end

end

end

function avgMvData(src,event)
    global daqData
    daqData = mean(event.Data,1);
end