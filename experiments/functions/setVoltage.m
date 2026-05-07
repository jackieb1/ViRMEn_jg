function setVoltage(s, volts)
    volts = max(0, min(5, volts));
    outputSingleScan(s, volts);
end