function velocity = dualSensor_noRotation_CA_Rig2(vr)

velocity = [0 0 0 0];
% velocity in the form (d/dt)*x, y, z, viewAngle
% units of [1:3]: Virmen space units/second, unit [4]: radians/second
% velocity * vr.dt(i.e. time elapsed since last iteration) = vr.dp
% (displacement vector)

% Access global mvData
% data: 1: roll (longitudinal axis); 2: pitch (lateral axis); 3: yaw

global mvData;
data = mvData;
data = data(1:3);
%disp(data)

%offsetBallAir = [ 1.6810    1.6823    1.6822]; % calibrated on 170829
offsetBallAir = [1.6691    1.6741    1.6747]; %calibrated on 180115
data = data - offsetBallAir;

lateralReduction = 1; 
velocity(1) = vr.alpha*data(2)/lateralReduction; % speed in x direction
velocity(2) = vr.alpha*data(1);    % speed in y direction

