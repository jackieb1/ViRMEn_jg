function velocity = moveWithTwoSensors_lateral(vr)
global daqData
global mvData
velocity = [0 0 0 0];

if isempty(daqData)
    return
end

% Access global mvData
% Teensy can send voltage between 0 and 3.3V, so that ~1.65 V 
% corresponds to no movement. This voltage needs calibration 
% because there is subtle fluctuations from day to day.
data = daqData(1:3) - vr.ops.ballSensorOffset;

% data
% 1: pitch
% 2: roll
% 3: yaw

% Update velocity
alpha = vr.ops.forwardGain * vr.pitchGain;
beta = vr.ops.sideGain * vr.sideGain;

velocity(1) = -beta*data(2) + vr.sideOffset;
velocity(2) = alpha*data(1);
velocity(4) = 0;
