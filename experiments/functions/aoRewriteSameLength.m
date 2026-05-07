function vr = aoRewriteSameLength(vr, newPulse)
import NationalInstruments.DAQmx.*

y = single(newPulse(:)).';
N = int32(numel(y));

% Ensure not running
try vr.task.Stop(); end

% (Re)assert the sample count (same N is fine)
vr.task.Timing.SamplesPerChannel = N;

% Overwrite from the beginning
s = vr.task.Stream;
try
    s.WriteRelativeTo = WriteRelativeTo.FirstSample;
    s.WriteOffset     = int32(0);
end

vr.writer = AnalogSingleChannelWriter(s);      % rebind writer (safe)
vr.writer.WriteMultiSample(false, y);          % stays Idle
end