function vr = initStepperMotor(vr)

% clear the workspace of any previous existing stepper motor objects
clear a sm shield;
% create stepper motor connection with 200 steps per revolution, RPM:
% revolutions per minute: determines speed ( default: 0)
vr.ard = arduino('COM3', 'Uno', 'Libraries', 'Adafruit\MotorShieldV2');
vr.shield = addon(vr.ard, 'Adafruit\MotorShieldV2');
vr.sm = stepper(vr.shield, 2, 200, 'RPM',20, 'StepType', 'Double');

end