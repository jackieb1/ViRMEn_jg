function aoSetPulse(ao, fs, vHigh, pulse_ms, post_ms)
    nHigh = max(1, round(pulse_ms/1000 * fs));
    nPost = max(1, round(post_ms /1000 * fs));
    y = [vHigh*ones(nHigh,1); zeros(nPost,1)];
    s = ao.UserData.ctrl; s.nextWave = y; ao.UserData.ctrl = s;
end