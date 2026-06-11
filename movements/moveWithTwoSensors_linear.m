function velocity = moveWithTwoSensors_linear(vr)

velocity = [0 0 0 0];

% Access global mvData
global daqData
data = daqData(1:3) - vr.ops.ballSensorOffset;

viewAngleGain = 0;%vr.ops.viewAngleGain;

% Deadband on the forward (pitch) channel to suppress resting +/-1-count
% sensor jitter. When the ball is still the ADNS reports a count or two of
% noise; treat anything within +/- forwardDeadband volts of the calibrated
% offset as no motion. Tune ops.forwardDeadband in getRigInfo to just above
% the resting fluctuation seen on data(1).
if isfield(vr.ops, 'forwardDeadband') && abs(data(1)) < vr.ops.forwardDeadband
    data(1) = 0;
end

% Update velocity
forwardVelocity = vr.ops.forwardGain*data(1) + vr.forwardBias;
viewAngleVelocity = viewAngleGain*data(2);

velocity(1) = -forwardVelocity*sin(vr.position(4));
velocity(2) = forwardVelocity*cos(vr.position(4));
velocity(4) = viewAngleVelocity;


% disp(vr.position);
% disp([vr.position velocity]);