function vr = opto_sustained_pulsed(vr)

test = true;
if test
    vr.ops.dev = 'Dev1';
    vr.ao0 = daq.createSession('ni');
    vr.ao0.addAnalogOutputChannel(vr.ops.dev,'ao0','Voltage');
    vr.ao0.Rate = 1e3;
    
    vr.ao1 = daq.createSession('ni');
    vr.ao1.addAnalogOutputChannel(vr.ops.dev,'ao1','Voltage');
    vr.ao1.Rate = 1e3;
end

vr.ops.optoAO0_V = 0;
vr.ops.optoAO1_V = 2;
vr.Fs = 1e3;
vr.optoFreq = 40;
vr.optoDutyCycle = 50;
vr.optoDur = 15;
t = 0:1/vr.Fs:vr.optoDur - 1/vr.Fs;
vr.optoSquareWave = (square(2*pi*vr.optoFreq*t, vr.optoDutyCycle)+1)'/2;
vr.optoTrialProbability = 0.5;
% vr.ao0.IsContinuous = true;
% vr.ao1.IsContinuous = true;

% load data
vr.ao0.queueOutputData(vr.optoSquareWave*vr.ops.optoAO0_V);
vr.ao1.queueOutputData(vr.optoSquareWave*vr.ops.optoAO1_V);

% start stim
vr.ao0.startForeground;
vr.ao1.startForeground;

% reset
stop(vr.ao0)
stop(vr.ao1)
delete(vr.ao0)
delete(vr.ao1)
daqreset;

% calibration
% A01 0.05V = 0.9 mW
% AO1 0.05V = 0.9 mW