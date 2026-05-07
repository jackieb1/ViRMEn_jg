function [vr] = outputOptoTrigger(vr)
disp('Sending opto trigger!')
outputSingleScan(vr.optoDIO,[1]);
% java.lang.Thread.sleep(10);
outputSingleScan(vr.optoDIO,[0]);
vr.optoFired = true;
end

