function velocity = moveWithTwoSensors_linear_forwardPulse(vr)

velocity = [0 0 0 0];

% Access global mvData
global daqData
if isempty(daqData)
    return
end
data = daqData(1:3) - vr.ops.ballSensorOffset;

viewAngleGain = 0;%vr.ops.viewAngleGain;

% Deadband on the forward (pitch) channel to suppress resting sensor jitter
if isfield(vr.ops, 'forwardDeadband') && abs(data(1)) < vr.ops.forwardDeadband
    data(1) = 0;
end

% Update velocity (pitchGain is modulated by forwardDriftGainPulse)
forwardVelocity = vr.ops.forwardGain*vr.pitchGain*data(1) + vr.forwardBias;
viewAngleVelocity = viewAngleGain*data(2);

velocity(1) = -forwardVelocity*sin(vr.position(4));
velocity(2) = forwardVelocity*cos(vr.position(4));
velocity(4) = viewAngleVelocity;
