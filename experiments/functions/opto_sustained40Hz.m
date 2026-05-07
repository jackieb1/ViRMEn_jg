function vr = opto_sustained_pulsed(vr)

vr.Fs = 1e3;
vr.optoFreq = 40;
vr.optoDutyCycle = 50;
vr.optoDur = 0.5;
t = 0:1/vr.Fs:vr.optoDur - 1/vr.Fs;
vr.optoSquareWave = (square(2*pi*vr.optoFreq*t, vr.optoDutyCycle)+1)'/2;
vr.optoTrialProbability = 0.5;
vr.ao0.IsContinuous = true;
vr.ao1.IsContinuous = true;