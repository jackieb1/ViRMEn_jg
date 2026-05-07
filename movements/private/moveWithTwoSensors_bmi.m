function velocity = moveWithTwoSensors_bmi(vr)
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
%disp(size(daqData));
data = daqData-[1.4704    1.4770 1.4704    0];% -[1.5051   1.4965];%-[1.4926    1.4960    1.4966];%-[1.5047    1.4964    1.4961];%- [1.50    1.4960    1.4963];%-[1.493    1.4939    1.4875];% -[1.4916    1.4951    1.4958];

%disp(data);
% data
% 1: pitch
% 2: yaw
% 3: decoded pitch
% 4: decoded yaw

% Update velocity
V = 0.32; % integral of voltage over one rotation of the ball
circum = 64; % circumference of the ball 
% 100 unit is defined as 75 cm
%alpha = -100/75*circum/V;
alpha = -50/75*circum/V; % changed from 50/
flip = 1; % set to 1 if the mirror flips right and left in Virme9n 
% use pitch and yaw only
beta = 0.05*circum/V/2.5;
 beta = 2*pi/V/2.5;
    velocity(1) = -alpha*data(1)*sin(vr.position(4));
    velocity(2) = alpha*data(1)*cos(vr.position(4));
    velocity(4) = beta*data(2);
    %disp('using this function');
    if flip
        velocity(4) = -beta*data(2);
    end
    if vr.position(2)> 50 && vr.numRewards>10%  && vr.position(2)<200 && vr.trialType==2
        velocity(1) = -alpha*data(3)*sin(vr.position(4));
        velocity(2) = alpha*data(3)*cos(vr.position(4));
        velocity(4) = beta*data(2);
        disp('using this function');
        if flip
            velocity(4) = -beta*data(2);
        end
%     end;
%disp(velocity)
end