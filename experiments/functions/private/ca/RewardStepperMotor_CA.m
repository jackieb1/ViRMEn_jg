%% control stepper motor with Arduino for reward delivery

a = arduino('COM3', 'Uno', 'Libraries', 'Adafruit\MotorShieldV2');
shield = addon(a, 'Adafruit\MotorShieldV2');

% create stepper motor connection with 200 steps per revolution, RPM:
% revolutions per minute: determines speed ( default: 0)
sm = stepper(shield, 2, 200, 'RPM',50, 'StepType', 'Double');

%%

pause(1)%seconds 
move(sm,20);       %25=4ul    to fill use large neg number

%%
%pause(2);

for i = 1:3
    
move(sm,-500); % calibrated on 170428 to give 4 mikroliters of reward 
pause(3);

% release(sm);
end
