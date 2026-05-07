vr.optoDIO = daq.createSession('ni');
vr.optoDIO.addDigitalChannel('dev2','Port0/Line7','OutputOnly');

for trialNumber = 1:2310
    disp([num2str(trialNumber), 'out of ', num2str(50)]);
    outputSingleScan(vr.optoDIO,[1]);
% java.lang.Thread.sleep(10);
    outputSingleScan(vr.optoDIO,[0]);
    java.lang.Thread.sleep(500);
end;