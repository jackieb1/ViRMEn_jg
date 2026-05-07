function vr = initDAQ_Cam_Photostim(vr)
% initialises the DAQ settings for Virmen, including camera hardware
% triggering and photostim PC triggering

% Start the DAQ acquisition
if ~vr.debugMode
    daqreset; %reset DAQ in case it's still in use by a previous Matlab program
    % set up analog inputs as ai session
    vr.ai = daq.createSession('ni');
    
    % set up ball signal inputs
    h1 = vr.ai.addAnalogInputChannel('dev1','ai0','Voltage'); % pitch
    h1.TerminalConfig = 'SingleEnded';
    h2 = vr.ai.addAnalogInputChannel('dev1','ai1','Voltage'); % yaw
    h2.TerminalConfig = 'SingleEnded';
    h3 = vr.ai.addAnalogInputChannel('dev1','ai2','Voltage'); % roll
    h3.TerminalConfig = 'SingleEnded';
    
    h4 = vr.ai.addAnalogInputChannel('dev1','ai4','Voltage'); % lick detector
    h4.TerminalConfig = 'SingleEnded';
    
    vr.ai.Rate = 1e3;
    vr.ai.NotifyWhenDataAvailableExceeds=50;
    vr.ai.IsContinuous=1;
    vr.aiListener = vr.ai.addlistener('DataAvailable', @avgMvData);
    startBackground(vr.ai),
    pause(1e-2),

    % set up analog outputs as ao session
    vr.ao = daq.createSession('ni');
    vr.ao.addAnalogOutputChannel('dev1','ao0','Voltage'); 
    vr.ao.Rate = 1e4;
    
    % set up digital outputs as dio session
    vr.dio = daq.createSession('ni');
    addDigitalChannel(vr.dio, 'dev1', 'Port0/Line0','OutputOnly'); % digital out for triggering camera on every virmen iteration 
    % (use this channel (split it) to also send a signal to the Photostim computer so
    % that it knows the timing of each virmen iteration)
    
    vr.dio_photostim = daq.createSession('ni');
    addDigitalChannel(vr.dio_photostim, 'dev1',  'Port0/Line1','OutputOnly'); % digital out for triggering the Photostim PC
end

end

function avgMvData(src,event)
    global mvData
    mvData = mean(event.Data,1);
end