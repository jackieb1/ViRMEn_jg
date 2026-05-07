function velocity = dualSensor_noRotation(vr)

velocity = [0 0 0 0];

% Access global mvData
global mvData
data = mvData;

offset = [1.685 1.686 1.686]; %calibrated 8/4, 9/7 AH

data = data - offset;

% Update velocity
alpha = -115; %-44
lateralReduction = 2;
velocity(1) = (-alpha*data(2))/lateralReduction;
velocity(2) = alpha*data(1);