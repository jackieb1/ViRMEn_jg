function velocity = dualSensor_noRotation(vr)

velocity = [0 0 0 0];
% velocity in the form (d/dt)*x, y, z, viewAngle
% units of [1:3]: Virmen space units/second, unit [4]: radians/second
% velocity * vr.dt(i.e. time elapsed since last iteration) = vr.dp
% (displacement vector)

% Access global mvData
% data: 1: roll (longitudinal axis); 2: pitch (lateral axis); 3: yaw

global mvData;
data = mvData;
data = data(1:3); % only use first 3 indices for movement function
%disp(data)

%offsetBallAir =  [1.6746    1.6765    1.6762];
offsetBallAir =  [1.6886    1.6941    1.6942]; %Calibrated 15-01-18

data = data - offsetBallAir;

% Update velocity
vr.alpha = -125; %-44
%alpha = -100; % 170705 for mouse 2, otherwise -125

lateralReduction = 2; 
velocity(1) = vr.alpha*data(2)/lateralReduction; % speed in x direction
velocity(2) = vr.alpha*data(1);    % speed in y direction
