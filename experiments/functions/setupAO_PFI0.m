function vr = setupAO_PFI0(vr)
% setupAO_PFI0  Prepare USB-6003 AO0 to fire a finite pulse on /PFI0 rising edge.

NET.addAssembly('NationalInstruments.DAQmx');
import NationalInstruments.DAQmx.*

dev = vr.ops.dev;                       % e.g., 'Dev1'
fs  = vr.Rate;                            % AO rate (Hz) ? set what you want
y   = single(vr.yPulse(:)).';           % row vector; matches fs (e.g., 25 ms + 5 ms)

% --- Task + channel ---
vr.task = NationalInstruments.DAQmx.Task();
vr.task.AOChannels.CreateVoltageChannel([dev '/ao0'], '', 0, 5, AOVoltageUnits.Volts);

% --- Sample-clocked timing (finite) in one call ---
vr.task.Timing.ConfigureSampleClock( ...
    '', ...                               % OnboardClock
    fs, ...
    SampleClockActiveEdge.Rising, ...
    SampleQuantityMode.FiniteSamples, ...
    int32(numel(y)) );

% --- Hardware start trigger on PFI0 (rising) ---
vr.task.Triggers.StartTrigger.ConfigureDigitalEdgeTrigger(['/' dev '/PFI0'], ...
    DigitalEdgeStartTriggerEdge.Rising);

% --- Preload buffer and ARM (autoStart = true) ---
streamObj = vr.task.Stream;   % or: NET.getProperty(vr.task,'Stream')
% Allow reuse of the same buffer between triggers
streamObj.WriteRegenerationMode = WriteRegenerationMode.AllowRegeneration;
vr.task.SynchronizeCallbacks = true;
vr.task.Stream.ConfigureOutputBuffer(int32(numel(y))); % pre-size the host output buffer
% % Auto re-arm on completion (Done event)
% vr.lh = addlistener(vr.task,'Done', @onDoneRearm);
% setappdata(0, 'aoDoneListener', vr.lh);           % pin on the root (groot)
% Preload but keep IDLE (no arming yet)
vr.writer  = AnalogSingleChannelWriter(streamObj);
vr.writer.WriteMultiSample(false, y);      % task goes to Running and WAITS for PFI0

assignin('base','vr',vr);       % ensure base has the same vr the callback will read
    
% NOTE: Do NOT call vr.task.Start() here; it?s already armed.
% NOTE: Do NOT call WriteSingleSample on this task (that?s on-demand timing).

end