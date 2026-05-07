%%
daqreset;
ai = daq.createSession('ni');

addDigitalChannel(ai,'dev1','Port0/Line1','OutputOnly');


%%

%stop(vid);
outputSingleScan(ai, 1)
pause(0.0005)
outputSingleScan(ai,0)