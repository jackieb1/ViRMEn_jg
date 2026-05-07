function [outputArg1,outputArg2] = optoCalibration(dur, freq, V)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    ops = getRigInfo();
    % init daq
    vr.ao = daq.createSession('ni');
    
    vr.ao.addAnalogOutputChannel(ops.dev, 'ao0', 'Voltage');
    vr.ao.addAnalogOutputChannel(ops.dev, 'ao1', 'Voltage');
    vr.ao.Rate = 1e3;

    % queue pulsed data
    Fs = 1e3;
    dutyCycle = 50;
    t = 0:1/Fs:dur - 1/Fs;
    optoSquareWave1 = (square(2*pi*freq*t, dutyCycle)+1)'/2;
    optoSquareWave = repmat(optoSquareWave1, [1, 2]);
    vr.ao.queueOutputData(optoSquareWave.*V);
    
    vr.ao.startBackground;
    pause(dur)
    stop(vr.ao)
    vr.ao.outputSingleScan([0, 0]);
    delete(vr.ao)
    daqreset
end