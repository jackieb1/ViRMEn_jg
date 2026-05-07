function firePulse(s, volts, duration_ms)
    volts = max(0, min(5, volts));            % clamp to safe 0–5 V
    nHigh = round((duration_ms/1000) * s.Rate);
    y = [volts * ones(nHigh, 1); 0];          % waveform: high → zero
    queueOutputData(s, y);
    startBackground(s);                       % non-blocking hardware-timed pulse
end