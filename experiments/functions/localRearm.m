function localRearm(ao)
    % force baseline in case device holds last sample
    try, outputSingleScan(ao,0); end %#ok<TRYNC>
    if ~isvalid(ao), return; end
    s = ao.UserData.ctrl;
    if ~s.enable, return; end                    % skip next trigger if disabled
    if ~isempty(s.nextWave)
        queueOutputData(ao, s.nextWave);         % preload next waveform
        startBackground(ao);                     % re-arm: wait for next PFI0 rising edge
    end
end