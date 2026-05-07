dio = daq.createSession('ni');
dio.addDigitalChannel('dev1' ,'Port0/Line7','OutputOnly');
nCells = 5;
nTrials = 50; %100
iti = 10; % interstim time in seconds
for i = 1:nCells*nTrials
    h = tic;
    disp(i);
    outputSingleScan(dio,[1]);
    java.lang.Thread.sleep(20);
    outputSingleScan(dio,[0]);

    java.lang.Thread.sleep(iti*1000);
    times(i) = toc(h);
end;  

