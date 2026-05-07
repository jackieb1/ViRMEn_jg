function [vr] = giveReward(vr,nRew)
%giveReward Function which delivers rewards using the Master-8 system
%(instantaneous pulses)
%   nRew - number of rewards to deliver

sinDur = 0.055; %calibrated to give 4.3ul per reward
%.065; % 101323: calibrated to give 4.3 ul for single reward (with ca 10 ml milk in 60 ml syringe)
% 120932: calibrated to give 3.7 ul for a single reward
% 171216: calibrated to give 4 mikroliter rewards

if ~vr.debugMode
    actualRate = vr.ao.Rate; %get sample rate
    pulselength=round(actualRate*sinDur*nRew); %find duration (rate*duration in seconds *numRew)
    pulsedata=5.0*ones(pulselength,1); %5V amplitude
    pulsedata(pulselength)=0; %reset to 0V at last time point
    vr.ao.queueOutputData(pulsedata);
    startForeground(vr.ao);
end

vr.isReward = nRew;

end