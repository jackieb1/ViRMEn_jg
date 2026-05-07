function vr = aoRearmIfIdle(vr)
% Re-arm AO for next /PFI0 edge, even if DAQmx state is in-between.
% Safe to call every engine tick.

import NationalInstruments.DAQmx.*

try
    if ~vr.task.IsDone
        return;                       % already armed/running
    end

    % 1) Force Idle (safe if already Done)
    try vr.task.Stop(); end

    % 2) Make sure buffer definition matches data
    y = single(vr.yPulse(:)).';
    N = int32(numel(y));
    if vr.task.Timing.SamplesPerChannel ~= N
        vr.task.Timing.SamplesPerChannel = N;
    end

    % 3) Reset write pointer and (re)queue data (defensive)
    s = vr.task.Stream;
    try
        s.WriteRelativeTo = WriteRelativeTo.FirstSample;
        s.WriteOffset     = int32(0);
    end
    vr.writer.WriteMultiSample(false, y);   % preload, stay Idle

    % 4) Tiny yield helps DAQmx finalize Done?Idle
    pause(0);                               

    % 5) Arm (waits for next /PFI0)
    vr.task.Start();

catch ME
    % Ignore benign "cannot perform while task is running"
    if ~contains(ME.message,'-200479')
        warning('[aoRearmIfIdle] %s', ME.message);
    end
end