function velocity = moveWithTwoSensors(vr)
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
data = daqData(1:3)-[1.4927 1.496 1.4968];

%disp(data);
% data
% 1: pitch
% 2: roll
% 3: yaw

% Update velocity
V = 0.32; % integral of voltage over one rotation of the ball
circum = 64; % circumference of the ball 
% 100 unit is defined as 75 cm
%alpha = -100/75*circum/V;
alpha = -50/75*circum/V; % changed from 50/
flip = 1; % set to 1 if the mirror flips right and left in Virme9n 
if 0
    disp('using yaw');
    % use roll, pitch, and yaw
    beta = 2*pi/V/4; % changed from /5
    velocity(1) = alpha*(data(2)*cos(vr.position(4)) + data(1)*sin(vr.position(4)));
    velocity(2) = alpha*(data(2)*sin(vr.position(4)) - data(1)*cos(vr.position(4)));
    velocity(4) = beta*data(3);
    if flip
        velocity(1) = alpha*(data(2)*cos(vr.position(4)) - data(1)*sin(vr.position(4)));
        velocity(2) = alpha*(data(2)*sin(vr.position(4)) + data(1)*cos(vr.position(4)));
        velocity(4) = -beta*data(3);
    end
else
    % use roll and yaw only
    beta = 0.01*circum/V/1.5;%/1.75;
    %disp('Using roll and pitch');
     %beta = 2*pi/V/2.5;
    velocity(1) = -alpha*data(1)*sin(vr.position(4));
    velocity(2) = alpha*data(1)*cos(vr.position(4));
    velocity(4) = beta*data(3);
    %disp('using this function');
    if flip
        velocity(4) = -beta*data(3);
    end
%     if vr.position(2)<vr.cueLength+vr.floorLength
%         velocity(4)=0;
%     end;
%disp(velocity)
end