function opto_test_pulse(ops, V)

ao0 = daq.createSession('ni');
ao0.addAnalogOutputChannel(ops.dev, 'ao0', 'Voltage');

ao1 = daq.createSession('ni');
ao1.addAnalogOutputChannel(ops.dev, 'ao1', 'Voltage');

ao0.outputSingleScan(V)
ao1.outputSingleScan(V)
pause(1)
ao0.outputSingleScan(0)
ao1.outputSingleScan(0)

delete(ao0)
delete(ao1)