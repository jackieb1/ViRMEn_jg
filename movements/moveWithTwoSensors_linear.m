function velocity = moveWithTwoSensors_linear(vr)

velocity = [0 0 0 0];

% Access global mvData
global daqData
data = daqData(1:3) - vr.ops.ballSensorOffset;

viewAngleGain = 0;%vr.ops.viewAngleGain;

% Update velocity
forwardVelocity = vr.ops.forwardGain*data(1) + vr.forwardBias;
viewAngleVelocity = viewAngleGain*data(2);

velocity(1) = -forwardVelocity*sin(vr.position(4));
velocity(2) = forwardVelocity*cos(vr.position(4));
velocity(4) = viewAngleVelocity;


% disp(vr.position);
% disp([vr.position velocity]);