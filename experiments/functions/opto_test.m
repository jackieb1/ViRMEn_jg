function opto_test(ops, ch, V)

ao = daq.createSession('ni');
ao.addAnalogOutputChannel(ops.dev, ch, 'Voltage');
ao.outputSingleScan(V)
delete(ao)