function [vr] = outputVirmenTrigger(vr)
outputSingleScan(vr.dio,[1]);
java.lang.Thread.sleep(2); % Ensure that DAQ sees it at 2kHz
outputSingleScan(vr.dio,[0]);
end

