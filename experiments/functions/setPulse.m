function vr = setPulse(vr)
% setPulse  Overwrite the AO buffer with a new pulse (call before Start()).
vr.task.Timing.SamplesPerChannel = int32(numel(vr.yPulse));
vr.writer.WriteMultiSample(false, vr.yPulse');
end