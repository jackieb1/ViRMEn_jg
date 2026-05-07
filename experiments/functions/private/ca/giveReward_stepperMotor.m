function [vr] = giveReward_stepperMotor(vr,nRew, sm)
%Function which delivers rewards using the SyringePump driven by stepper
%motor

%   nRew - number of rewards to deliver

if ~vr.debugMode
  % move(sm, 25*nRew); % calibrated to give 4 mikroliters when using 200 SRV (steps per revolution)
   % move(sm, 15*nRew); % 170519: give smaller rewards to have longer sessions with 1ml syringe, should be ca 2.4 mikroliter per reward
   move(sm, 20*nRew); % gives 3.2 ul reward
end

vr.isReward = nRew;

end